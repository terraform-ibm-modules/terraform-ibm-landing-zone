package test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"reflect"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const quickstartExampleTerraformDir = "examples/quickstart"
const roksPatternTerraformDir = "patterns/roks"
const vsiPatternTerraformDir = "patterns/vsi"
const vpcPatternTerraformDir = "patterns/vpc"
const resourceGroup = "geretain-test-resources"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Setting "add_atracker_route" to false for VPC and VSI tests to avoid hitting AT route quota, right now its 4 routes per account.
const add_atracker_route = false

// Temp: the atracker_target ignore is being tracked in https://github.ibm.com/GoldenEye/issues/issues/4302
var ignoreUpdates = []string{
	"module.landing_zone.module.landing_zone.ibm_atracker_target.atracker_target[0]",
	"module.landing_zone.ibm_atracker_target.atracker_target[0]",
}

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

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		TerraformVars: map[string]interface{}{
			"ssh_key": sshPublicKey,
		},
		IgnoreUpdates: testhelper.Exemptions{
			List: ignoreUpdates,
		},
		CloudInfoService: sharedInfoSvc,
	})

	return options
}

func TestRunQuickstartExample(t *testing.T) {
	t.Parallel()
	os.Setenv("TF_VAR_ibmcloud_api_key", "0t4ZxnmwzJBCGxES03ZV6_HCsZp3zF4PWu-TBwEDFh2O") //TODO: Remove this line
	options := setupOptions(t, "slz-qs", quickstartExampleTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeQuickstartExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "slz-qs-ug", quickstartExampleTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsRoksPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  roksPatternTerraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		IgnoreUpdates: testhelper.Exemptions{
			List: ignoreUpdates,
		},
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"ssh_public_key": sshPublicKey,
		"prefix":         options.Prefix,
		"tags":           options.Tags,
		"region":         options.Region,
	}

	return options
}

func TestRunRoksPatternWithHPCS(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "lrkshp")

	// TODO: Use HPCS instead of Key Protect for tests once the auth policy issue is fixed. Issue: https://github.ibm.com/GoldenEye/issues/issues/5138

	// Key Protect service will be used if `hs_crypto_instance_name` is null
	// options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	// options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeRoksPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "r-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsVsiPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  vsiPatternTerraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		IgnoreUpdates: testhelper.Exemptions{
			List: ignoreUpdates,
		},
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

	options := setupOptionsVsiPattern(t, "vp-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunVSIPatternWithHPCS(t *testing.T) {
	options := setupOptionsVsiPattern(t, "lvsihp")

	// TODO: Use HPCS instead of Key Protect for tests once the auth policy issue is fixed. Issue: https://github.ibm.com/GoldenEye/issues/issues/5138

	// Key Protect service will be used if `hs_crypto_instance_name` is null
	// options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	// options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func setupOptionsVpcPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  vpcPatternTerraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		IgnoreUpdates: testhelper.Exemptions{
			List: ignoreUpdates,
		},
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

	options := setupOptionsVpcPattern(t, "p-vpc")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeVpcPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVsiPattern(t, "vpc-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

// ---------- JSON EXAMPLE: In Progress -----
func getOverrideInfo(filePath string) []byte {
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Println(err)
		// return
	}
	defer file.Close()

	fileBytes, err := ioutil.ReadAll(file)
	if err != nil {
		fmt.Println("Error reading the file contents.")
		// return
	}
	return fileBytes
}

func getConfigOutput(t *testing.T) (*terraform.PlanStruct, error) {
	os.Setenv("TF_VAR_override", "true")

	options := setupOptions(t, "slz-qs-compare", quickstartExampleTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
	os.Unsetenv("TF_VAR_override")
	return output, err

}
func TestJsonComparison(t *testing.T) {

	var overrideJson map[string]interface{}
	var configJson map[string]interface{}
	overridePath := "../patterns/vsi/override.json"
	// configPath := ""

	// Read the contents of the override.json file
	overrideData := getOverrideInfo(overridePath)
	fmt.Println(overrideData)
	errOverride := json.Unmarshal(overrideData, &overrideJson)
	assert.NoError(t, errOverride, "Error unmarshaling override json.")

	// Read the contents of the config.json file
	configData, _ := getConfigOutput(t)
	errConfigPath := json.Unmarshal(configData, &configJson)
	assert.NoError(t, errConfigPath, "Error unmarshaling Config json.")

	// Compare the JSON objects
	assert.True(t, reflect.DeepEqual(overrideJson, configJson), "JSON objects are not equal")

}
