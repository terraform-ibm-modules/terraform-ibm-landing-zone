package test

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const quickStartPatternTerraformDir = "patterns/vsi-quickstart"
const roksQuickstartPatternTerraformDir = "patterns/roks-quickstart"
const roksPatternTerraformDir = "patterns/roks"
const vsiPatternTerraformDir = "patterns/vsi"
const vpcPatternTerraformDir = "patterns/vpc"
const overrideExampleTerraformDir = "examples/override-example"
const resourceGroup = "geretain-test-resources"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Setting "add_atracker_route" to false for VPC and VSI tests to avoid hitting AT route quota, right now its 4 routes per account
const add_atracker_route = false

const user_data = `{
  management = {
    user_data = <<-EOT
#cloud-config
# vim: syntax=yaml
write_files:
- content: |
    # This is management

  path: /etc/sysconfig/management
EOT
  }
  workload = {
    user_data = <<-EOT
#cloud-config
# vim: syntax=yaml
write_files:
- content: |
    # This is workload

  path: /etc/sysconfig/workload
EOT
  }
}`

var sharedInfoSvc *cloudinfo.CloudInfoService
var permanentResources map[string]interface{}

// Turn on Schematics tests, which can also skip the normal tests for same pattern
var enableSchematicsTests bool

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	// ENABLE SCHEMATICS TESTS
	// To enable Schematics tests, and skip terratest for patterns, set boolean to true
	enableSchematicsTests = true

	os.Exit(m.Run())
}

func sshPublicKey(t *testing.T) string {
	pubKey, keyErr := common.GenerateSshRsaPublicKey()

	// if error producing key (very unexpected) fail test immediately
	require.NoError(t, keyErr, "SSH Keygen failed, without public ssh key test cannot continue")

	return pubKey
}

func setupOptionsQuickStartPattern(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		TerraformVars: map[string]interface{}{
			"ssh_key":             sshPublicKey,
			"provider_visibility": "public",
		},
		CloudInfoService: sharedInfoSvc,
	})

	return options
}

type tarIncludePatterns struct {
	excludeDirs []string

	includeFiletypes []string

	includeDirs []string
}

func getTarIncludePatternsRecursively(dir string, dirsToExclude []string, fileTypesToInclude []string) ([]string, error) {
	r := tarIncludePatterns{dirsToExclude, fileTypesToInclude, nil}
	err := filepath.WalkDir(dir, func(path string, entry fs.DirEntry, err error) error {
		return walk(&r, path, entry, err)
	})
	if err != nil {
		fmt.Println("error")
		return r.includeDirs, err
	}
	return r.includeDirs, nil
}

func walk(r *tarIncludePatterns, s string, d fs.DirEntry, err error) error {
	if err != nil {
		return err
	}
	if d.IsDir() {
		for _, excludeDir := range r.excludeDirs {
			if strings.Contains(s, excludeDir) {
				return nil
			}
		}
		if s == ".." {
			r.includeDirs = append(r.includeDirs, "*.tf")
			return nil
		}
		for _, includeFiletype := range r.includeFiletypes {
			r.includeDirs = append(r.includeDirs, strings.ReplaceAll(s+"/*"+includeFiletype, "../", ""))
		}
	}
	return nil
}

func TestRunQuickStartPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for Quickstart Pattern, running Schematics test instead")
	}

	options := setupOptionsQuickStartPattern(t, "vsi-qs", quickStartPatternTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeQuickStartPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for Quickstart Pattern upgrade, running Schematics test instead")
	}

	options := setupOptionsQuickStartPattern(t, "vsi-qs-u", quickStartPatternTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsROKSQuickStartPattern(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     dir,
		Prefix:           prefix,
		CloudInfoService: sharedInfoSvc,
		TerraformVars: map[string]interface{}{
			"entitlement":         "cloud_pak",
			"provider_visibility": "public",
		},
	})

	return options
}

func TestRunROKSQuickStartPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for ROKS Quickstart Pattern, running Schematics test instead")
	}

	options := setupOptionsROKSQuickStartPattern(t, "rokqs", roksQuickstartPatternTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeROKSQuickStartPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for ROKS Quickstart Pattern upgrade, running Schematics test instead")
	}

	options := setupOptionsROKSQuickStartPattern(t, "rokqsu", roksQuickstartPatternTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsRoksPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     roksPatternTerraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":                              options.Prefix,
		"tags":                                options.Tags,
		"region":                              options.Region,
		"entitlement":                         "cloud_pak",
		"flavor":                              "bx2.4x16",
		"enable_transit_gateway":              false,
		"use_ibm_cloud_private_api_endpoints": false,
		"verify_cluster_network_readiness":    false,
		"provider_visibility":                 "public",
	}

	return options
}

func TestRunRoksPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for ROKS Pattern, running Schematics test instead")
	}

	options := setupOptionsRoksPattern(t, "ocp")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeRoksPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for ROKS Pattern upgrade, running Schematics test instead")
	}

	options := setupOptionsRoksPattern(t, "ocp-u")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsVsiPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     vsiPatternTerraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"ssh_public_key":         sshPublicKey,
		"prefix":                 options.Prefix,
		"tags":                   options.Tags,
		"region":                 options.Region,
		"add_atracker_route":     add_atracker_route,
		"enable_transit_gateway": false,
		"provider_visibility":    "public",
	}

	return options
}

func TestRunVSIPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for VSI Pattern, running Schematics test instead")
	}

	options := setupOptionsVsiPattern(t, "vsi")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeVsiPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for VSI Pattern upgrade, running Schematics test instead")
	}

	options := setupOptionsVsiPattern(t, "vsi-u")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsVpcPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     vpcPatternTerraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":                 options.Prefix,
		"tags":                   options.Tags,
		"region":                 options.Region,
		"add_atracker_route":     add_atracker_route,
		"enable_transit_gateway": false,
		"provider_visibility":    "public",
	}

	return options
}

func TestRunVpcPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for VPC Pattern, running Schematics test instead")
	}

	options := setupOptionsVpcPattern(t, "vpc")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeVpcPattern(t *testing.T) {
	t.Parallel()
	if enableSchematicsTests {
		t.Skip("Skipping terratest for VPC Pattern upgrade, running Schematics test instead")
	}

	options := setupOptionsVpcPattern(t, "vpc-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunOverride(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickStartPattern(t, "slz-ovr", quickStartPatternTerraformDir)
	options.SkipTestTearDown = true
	output, err := options.RunTestConsistency()

	if assert.Nil(t, err, "This should not have errored") &&
		assert.NotNil(t, output, "Expected some output") &&
		assert.NotNil(t, options.LastTestTerraformOutputs, "Expected some Terraform outputs") {
		// set override json string with previous value of config output
		options.TerraformOptions.Vars["override_json_string"] = options.LastTestTerraformOutputs["config"]

		// TERRATEST uses its own internal logger.
		// The "show" command will produce a very large JSON to stdout which is printed by the logger.
		// We are temporarily turning the terratest logger OFF (discard) while running "show" to prevent large JSON stdout.
		options.TerraformOptions.Logger = logger.Discard
		planStruct, planErr := terraform.InitAndPlanAndShowWithStructE(options.Testing, options.TerraformOptions)
		options.TerraformOptions.Logger = logger.Default // turn log back on

		if assert.Nil(t, planErr, "This should not have errored") &&
			assert.NotNil(t, planStruct, "Expected some output") {
			testhelper.CheckConsistency(planStruct, options)
		}
	}
	options.TestTearDown()
}

func setupOptionsSchematics(t *testing.T, prefix string, dir string) *testschematic.TestSchematicOptions {

	excludeDirs := []string{
		".terraform",
		".docs",
		".github",
		".git",
		".idea",
		"common-dev-assets",
		"examples",
		"tests",
		"reference-architectures",
	}
	includeFiletypes := []string{
		".tf",
		".yaml",
		".py",
		".tpl",
	}

	tarIncludePatterns, recurseErr := getTarIncludePatternsRecursively("..", excludeDirs, includeFiletypes)

	// if error producing tar patterns (very unexpected) fail test immediately
	require.NoError(t, recurseErr, "Schematic Test had unexpected error traversing directory tree")

	// set up a schematics test
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:                t,
		TarIncludePatterns:     tarIncludePatterns,
		TemplateFolder:         dir,
		Prefix:                 prefix,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 120,
		CloudInfoService:       sharedInfoSvc,
	})

	return options
}

/***************************************************************************
SCHEMATICS TESTS
These schematics tests will only be run if the "RUN_SCHEMATICS_TESTS"
environment variable is set to "true" or "yes".
If not set, the normal terratest will be run for the patterns.
***************************************************************************/

func TestRunVSIQuickStartPatternSchematics(t *testing.T) {
	t.Parallel()
	if !enableSchematicsTests {
		t.Skip("Skipping Schematics Test for QuickStart Pattern, running terratest instead")
	}

	options := setupOptionsSchematics(t, "qs-sc", quickStartPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_key", Value: sshPublicKey(t), DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunROKSQuickStartPatternSchematics(t *testing.T) {
	t.Parallel()
	if !enableSchematicsTests {
		t.Skip("Skipping Schematics Test for ROKS QuickStart Pattern, running terratest instead")
	}

	options := setupOptionsSchematics(t, "rqs-sc", roksQuickstartPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "entitlement", Value: "cloud_pak", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunVSIPatternSchematics(t *testing.T) {
	t.Parallel()
	if !enableSchematicsTests {
		t.Skip("Skipping Schematics Test for VSI Pattern, running terratest instead")
	}

	options := setupOptionsSchematics(t, "vsi-sc", vsiPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_public_key", Value: sshPublicKey(t), DataType: "string"},
		{Name: "add_atracker_route", Value: add_atracker_route, DataType: "bool"},
		{Name: "enable_transit_gateway", Value: false, DataType: "bool"},
		{Name: "user_data", Value: user_data, DataType: "map(object({ user_data = string }))"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunRoksPatternSchematics(t *testing.T) {
	t.Parallel()
	if !enableSchematicsTests {
		t.Skip("Skipping Schematics Test for ROKS Pattern, running terratest instead")
	}

	options := setupOptionsSchematics(t, "ocp-sc", roksPatternTerraformDir)

	options.WaitJobCompleteMinutes = 120

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "entitlement", Value: "cloud_pak", DataType: "string"},
		{Name: "flavor", Value: "bx2.4x16", DataType: "string"},
		{Name: "enable_transit_gateway", Value: false, DataType: "bool"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunVPCPatternSchematics(t *testing.T) {
	t.Parallel()
	if !enableSchematicsTests {
		t.Skip("Skipping Schematics Test for VPC Pattern, running terratest instead")
	}

	options := setupOptionsSchematics(t, "vpc-sc", vpcPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		// Here Region is set explicitly to 'us-east' to plug the test gap as mentioned here : https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/issues/928
		{Name: "region", Value: "us-east", DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "add_atracker_route", Value: add_atracker_route, DataType: "bool"},
		{Name: "enable_transit_gateway", Value: false, DataType: "bool"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunOverrideExample(t *testing.T) {
	t.Parallel()

	sshPublicKey := sshPublicKey(t)

	overrideJsonString, err := os.ReadFile("resources/override-example.json")
	if err != nil {
		panic(err)
	}

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: overrideExampleTerraformDir,
		Prefix:       "slz-ex",
		TerraformVars: map[string]interface{}{
			"ssh_key":              sshPublicKey,
			"override_json_string": string(overrideJsonString),
		},
		CloudInfoService: sharedInfoSvc,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
