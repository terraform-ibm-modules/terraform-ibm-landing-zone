// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// NOTE: The HPCS tests may fail if our account already has an existing hpcs auth policy - hence only running once a week so PR pipeline is not impacted
func TestRunRoksPatternWithHPCS(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "ocp-hp")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]
	options.TerraformVars["add_kms_block_storage_s2s"] = false
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

	options := setupOptionsVsiPattern(t, "vsi-hp")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]
	options.TerraformVars["add_kms_block_storage_s2s"] = false
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
