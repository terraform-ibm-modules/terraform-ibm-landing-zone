// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// NOTE: The HPCS tests may fail if our account already has an existing hpcs auth policy - hence only running once a week so PR pipeline is not impacted
func TestRunRoksPatternWithHPCS(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "slz-ocp-hpcs")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunVSIPatternWithHPCS(t *testing.T) {
	// Purposely not running in parallel so it does not clash with the auth policies created in "TestRunRoksPatternWithHPCS"
	// t.Parallel()

	options := setupOptionsVsiPattern(t, "slz-vsi-hpcs")

	options.TerraformVars["hs_crypto_instance_name"] = permanentResources["hpcs_name_south"]
	options.TerraformVars["hs_crypto_resource_group"] = permanentResources["hpcs_rg_south"]

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
