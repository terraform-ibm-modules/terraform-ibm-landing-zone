package test

import (
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"

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

var sharedInfoSvc *cloudinfo.CloudInfoService
var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

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

func TestRunQuickStartPattern(t *testing.T) {
	t.Parallel()

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

func TestRunUpgradeVsiPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVsiPattern(t, "vsi-u")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunVSIPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVsiPattern(t, "vsi")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
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
		assert.NotNil(t, output, "Expected some output") {
		outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)
		if assert.NotNil(t, outputs, "Expected some output") {
			// set override json string with previous value of config output
			options.TerraformOptions.Vars["override_json_string"] = outputs["config"]

			// Ran apply again and check for consistency, do not create new temp folder (options.SkipTestSetup = true)
			options.TerraformOptions.PlanFilePath = ""
			options.SkipTestSetup = true
			output2, err := options.RunTestConsistency()
			assert.Nil(t, err, "This should not have errored")
			assert.NotNil(t, output2, "Expected some output")
		}
	}
	options.TerraformOptions.Vars["override_json_string"] = ""
	options.TestTearDown()
}
