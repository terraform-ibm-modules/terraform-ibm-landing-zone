package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const noComputeExampleTerraformDir = "examples/no-compute-example"
const quickstartExampleTerraformDir = "examples/quickstart"
const roksPatternTerraformDir = "patterns/roks"
const vsiPatternTerraformDir = "patterns/vsi"
const resourceGroup = "geretain-test-resources"

// Temp: the atracker_target ignore is being tracked in https://github.ibm.com/GoldenEye/issues/issues/4302
// The ACL ignores can be removed once we merge this PR (https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/pull/315)
var ignoreUpdates = []string{
	"module.landing_zone.module.landing_zone.module.vpc[\"management\"].ibm_is_network_acl.network_acl[\"management-acl\"]",
	"module.landing_zone.module.vpc[\"management\"].ibm_is_network_acl.network_acl[\"management-acl\"]",
	"module.landing_zone.module.landing_zone.module.vpc[\"workload\"].ibm_is_network_acl.network_acl[\"workload-acl\"]",
	"module.landing_zone.module.vpc[\"workload\"].ibm_is_network_acl.network_acl[\"workload-acl\"]",
	"module.landing_zone.module.landing_zone.ibm_atracker_target.atracker_target[0]",
	"module.landing_zone.ibm_atracker_target.atracker_target[0]",
}

var sharedInfoSvc *cloudinfo.CloudInfoService

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	//	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})
	os.Exit(m.Run())
}

func sshPublicKey(t *testing.T) string {
	prefix := fmt.Sprintf("slz-test-%s", strings.ToLower(random.UniqueId()))
	actualTerraformDir := "./resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(actualTerraformDir, prefix)
	logger.Log(t, "Tempdir: ", tempTerraformDir)

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, terraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, terraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	}

	return terraform.Output(t, terraformOptions, "ssh_public_key")
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

// func TestRunNoComputeExample(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "slz-vpc", noComputeExampleTerraformDir)

// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }

// func TestRunUpgradeNoComputeExample(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "slz-ug", noComputeExampleTerraformDir)

// 	output, err := options.RunTestUpgrade()
// 	if !options.UpgradeTestSkipped {
// 		assert.Nil(t, err, "This should not have errored")
// 		assert.NotNil(t, output, "Expected some output")
// 	}
// }



// func TestRunUpgradeVsiPatternExample(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "p-vsi-ug", vsiPatternTerraformDir)

// 	output, err := options.RunTestUpgrade()
// 	if !options.UpgradeTestSkipped {
// 		assert.Nil(t, err, "This should not have errored")
// 		assert.NotNil(t, output, "Expected some output")
// 	}
// }

// func TestRunQuickstartExample(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "slz-qs", quickstartExampleTerraformDir)

// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }

// func TestRunUpgradeQuickstartExample(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptions(t, "slz-qs-ug", quickstartExampleTerraformDir)

// 	output, err := options.RunTestUpgrade()
// 	if !options.UpgradeTestSkipped {
// 		assert.Nil(t, err, "This should not have errored")
// 		assert.NotNil(t, output, "Expected some output")
// 	}
// }

// func setupOptionsRoksPattern(t *testing.T, prefix string) *testhelper.TestOptions {

// 	sshPublicKey := sshPublicKey(t)

// 	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
// 		Testing:       t,
// 		TerraformDir:  roksPatternTerraformDir,
// 		Prefix:        prefix,
// 		ResourceGroup: resourceGroup,
// 		IgnoreUpdates: testhelper.Exemptions{
// 			List: ignoreUpdates,
// 		},
// 		CloudInfoService: sharedInfoSvc,
// 	})

// 	options.TerraformVars = map[string]interface{}{
// 		"ssh_public_key": sshPublicKey,
// 		"prefix":         options.Prefix,
// 		"tags":           options.Tags,
// 		"region":         options.Region,
// 	}

// 	return options
// }


// func TestRunRoksPattern(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptionsRoksPattern(t, "s-no")

// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }

// func TestRunUpgradeRoksPattern(t *testing.T) {
// 	t.Parallel()

// 	options := setupOptionsRoksPattern(t, "r-ug")

// 	output, err := options.RunTestUpgrade()
// 	if !options.UpgradeTestSkipped {
// 		assert.Nil(t, err, "This should not have errored")
// 		assert.NotNil(t, output, "Expected some output")
// 	}
// }

func setupOptionsVsiPattern(t *testing.T, prefix string) *testhelper.TestOptions {

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


func TestRunVsiPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVsiPattern(t, "p-vsi")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
