package test

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const quickStartPatternTerraformDir = "patterns/vsi-quickstart"
const roksPatternTerraformDir = "patterns/roks"
const vsiPatternTerraformDir = "patterns/vsi"
const vpcPatternTerraformDir = "patterns/vpc"
const resourceGroup = "geretain-test-resources"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Setting "add_atracker_route" to false for VPC and VSI tests to avoid hitting AT route quota, right now its 4 routes per account.
const add_atracker_route = false

// Setting "service_endpoints" to `private` to test support for 'private' service_endpoints (schematics have access to private network).
const service_endpoints = "private"

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
			"ssh_key": sshPublicKey,
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

	options := setupOptionsQuickStartPattern(t, "vsi-qs-u", quickStartPatternTerraformDir)

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
		"prefix": options.Prefix,
		"tags":   options.Tags,
		"region": options.Region,
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
		"ssh_public_key":     sshPublicKey,
		"prefix":             options.Prefix,
		"tags":               options.Tags,
		"region":             options.Region,
		"add_atracker_route": add_atracker_route,
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
		"prefix":             options.Prefix,
		"tags":               options.Tags,
		"region":             options.Region,
		"add_atracker_route": add_atracker_route,
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
			options.CheckConsistency(planStruct)
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
		Prefix:                 "ocp-sc",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		CloudInfoService:       sharedInfoSvc,
	})

	return options
}

func TestRunVsiExtention(t *testing.T) {
	t.Parallel()

	sshPublicKey := sshPublicKey(t)

	// ------------------------------------------------------------------------------------
	// Deploy SLZ VPC first since it is needed for the landing-zone extension input
	// ------------------------------------------------------------------------------------

	prefix := fmt.Sprintf("vsi-slz-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := ".."
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	vpcTerraformDir := realTerraformDir + "/patterns/vpc"
	tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	// Programmatically determine region to use based on availability
	region, _ := testhelper.GetBestVpcRegion(val, "../common-dev-assets/common-go-assets/cloudinfo-region-vpc-gen2-prefs.yaml", "eu-de")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: vpcTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
			"region": region,
			"tags":   tags,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {
		outputVpcJson := terraform.OutputJson(t, existingTerraformOptions, "vpc_data")

		var managementVpcID string
		var vpcs []struct {
			VpcID   string `json:"vpc_id"`
			VpcName string `json:"vpc_name"`
		}
		// Unmarshal the JSON data into the struct
		if err := json.Unmarshal([]byte(outputVpcJson), &vpcs); err != nil {
			fmt.Println(err)
			return
		}
		// Loop through the vpcs and find the vpc_id when vpc_name is "<prefix>-management-vpc"
		for _, vpc := range vpcs {
			if vpc.VpcName == fmt.Sprintf("%s-management-vpc", prefix) {
				managementVpcID = vpc.VpcID
			}
		}

		outputKeysJson := terraform.OutputJson(t, existingTerraformOptions, "key_map")
		var keyID string
		var keys map[string]map[string]string
		// Unmarshal the JSON data into the map
		if err := json.Unmarshal([]byte(outputKeysJson), &keys); err != nil {
			fmt.Println(err)
			return
		}

		// Extract the key_id for the name "test-vsi-volume-key."
		if keyData, ok := keys[fmt.Sprintf("%s-vsi-volume-key", prefix)]; ok {
			keyID = keyData["crn"]
		} else {
			fmt.Println("Name 'test-vsi-volume-key' not found in the JSON data.")
		}
		// ------------------------------------------------------------------------------------
		// Deploy landing-zone extension
		// ------------------------------------------------------------------------------------
		options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
			Testing:      t,
			TerraformDir: "patterns/vsi-extension",
			TerraformVars: map[string]interface{}{
				"prefix":                     prefix,
				"region":                     region,
				"boot_volume_encryption_key": keyID,
				"vpc_id":                     managementVpcID,
				"ssh_public_key":             sshPublicKey,
			},
		})

		output, err := options.RunTestConsistency()
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		// ignore resource groups when destroying
		terraform.RunTerraformCommand(t, existingTerraformOptions, "state", "rm", "module.vpc_landing_zone.module.landing_zone.ibm_resource_group.resource_groups")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}

/***************************************************************************
SCHEMATICS TESTS
These schematics tests will only be run if the "RUN_SCHEMATICS_TESTS"
environment variable is set to "true" or "yes".
If not set, the normal terratest will be run for the patterns.
****************************************************************************/

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
		{Name: "service_endpoints", Value: service_endpoints, DataType: "string"},
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
		{Name: "service_endpoints", Value: service_endpoints, DataType: "string"},
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
		{Name: "service_endpoints", Value: service_endpoints, DataType: "string"},
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
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "add_atracker_route", Value: add_atracker_route, DataType: "bool"},
		{Name: "service_endpoints", Value: service_endpoints, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}
