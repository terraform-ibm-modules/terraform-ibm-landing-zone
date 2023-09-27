// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// NOTE: The HPCS tests may fail if our account already has an existing hpcs auth policy - hence only running once a week so PR pipeline is not impacted
func TestRunRoksPatternWithHPCS(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "ocp-hp")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]

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

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunRoksPatternSchematics(t *testing.T) {
	t.Parallel()

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
		TemplateFolder:         roksPatternTerraformDir,
		Prefix:                 "ocp-sc",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_key", Value: sshPublicKey(t), DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}

func TestRunVSIPatternSchematics(t *testing.T) {
	t.Parallel()

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
		TemplateFolder:         vsiPatternTerraformDir,
		Prefix:                 "ocp-sc",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_key", Value: sshPublicKey(t), DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}
