// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const overrideExampleTerraformDir = "examples/override-example"

// NOTE: The HPCS tests may fail if our account already has an existing hpcs auth policy - hence only running once a week so PR pipeline is not impacted
func TestRunRoksPatternWithHPCS(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "ocp-hp")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]
	options.TerraformVars["skip_kms_block_storage_s2s_auth_policy"] = true
	// If "jp-osa" was the best region selected, default to us-south instead.
	// "jp-osa" is currently not allowing hs-crypto be used for encrypting buckets in that region.
	currentRegion, ok := options.TerraformVars["region"]
	if ok && currentRegion == "jp-osa" {
		options.TerraformVars["region"] = "us-south"
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunVSIPatternWithHPCS(t *testing.T) {
	// Purposely not running in parallel so it does not clash with the auth policies created in "TestRunRoksPatternWithHPCS"
	// t.Parallel()

	t.Skip("Skipping Schematics Test for QuickStart Pattern, running terratest instead")

	options := setupOptionsVsiPattern(t, "vsi-hp")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]
	options.TerraformVars["skip_kms_block_storage_s2s_auth_policy"] = true
	// If "jp-osa" was the best region selected, default to us-south instead.
	// "jp-osa" is currently not allowing hs-crypto be used for encrypting buckets in that region.
	currentRegion, ok := options.TerraformVars["region"]
	if ok && currentRegion == "jp-osa" {
		options.TerraformVars["region"] = "us-south"
	}

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunOverrideExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickStartPattern(t, "slz-ex", overrideExampleTerraformDir)
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
