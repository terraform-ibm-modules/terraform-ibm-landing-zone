package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const defaultExampleTerraformDir = "examples/basic"
const quickstartExampleTerraformDir = "examples/quickstart"
const roksPatternTerraformDir = "patterns/roks"

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

func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: defaultExampleTerraformDir,
		Prefix:       prefix,
		TerraformVars: map[string]interface{}{
			"ssh_key": sshPublicKey,
		},
	})

	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "land-zone")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "lz-upg")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsQuickstart(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: quickstartExampleTerraformDir,
		Prefix:       prefix,
		TerraformVars: map[string]interface{}{
			"ssh_key": sshPublicKey,
		},
	})

	return options
}

func TestRunQuickstartExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickstart(t, "slz-qs")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeQuickstartExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickstart(t, "slz-qs-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsRoksPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: roksPatternTerraformDir,
		Prefix:       prefix,
		TerraformVars: map[string]interface{}{
			"ssh_key": sshPublicKey,
		},
	})

	return options
}

func TestRunRoksPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "slz-roks")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeRoksPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "slz-roks-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
