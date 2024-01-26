// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

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

func TestRunVSIQuickStartPatternSchematics(t *testing.T) {
	t.Parallel()

	options := setupOptionsSchematics(t, "qs-sc", quickStartPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_key", Value: sshPublicKey(t), DataType: "string"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunVSIPatternSchematics(t *testing.T) {
	t.Parallel()

	options := setupOptionsSchematics(t, "vsi-sc", vsiPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_public_key", Value: sshPublicKey(t), DataType: "string"},
		{Name: "add_atracker_route", Value: add_atracker_route, DataType: "bool"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunRoksPatternSchematics(t *testing.T) {
	t.Parallel()

	options := setupOptionsSchematics(t, "ocp-sc", roksPatternTerraformDir)

	options.WaitJobCompleteMinutes = 120

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunVPCPatternSchematics(t *testing.T) {
	t.Parallel()

	options := setupOptionsSchematics(t, "vpc-sc", vpcPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "add_atracker_route", Value: add_atracker_route, DataType: "bool"},
		{Name: "service_endpoints", Value: "private", DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}
