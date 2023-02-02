package test

import (
	"encoding/json"
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

const quickstartExampleTerraformDir = "examples/quickstart"
const roksPatternTerraformDir = "patterns/roks"
const resourceGroup = "geretain-test-resources"
const vsiTerraformDir = "patterns/vsi"

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

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  roksPatternTerraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})

	options.TerraformVars = map[string]interface{}{
		"ssh_public_key": sshPublicKey,
		"prefix":         options.Prefix,
		"tags":           options.Tags,
		"region":         options.Region,
	}

	return options
}

func TestRunRoksPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "r-no")

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

func setupOptionsOverride(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: vsiTerraformDir,
		Prefix:       prefix,
	})
	options.TerraformVars = map[string]interface{}{
		"ssh_public_key": sshPublicKey,
		"tags":           options.Tags,
		"region":         options.Region,
		"prefix":         options.Prefix,
	}

	return options
}

func TestRunOverrideExample(t *testing.T) {
	t.Parallel()
	options := setupOptionsOverride(t, "land-zone")

	logger.Log(options.Testing, "START: Init / Apply / Override Check")
	options.TestSetup()

	logger.Log(options.Testing, "Init and apply")
	_, err := terraform.InitAndApplyE(options.Testing, options.TerraformOptions)
	if err != nil {
		logger.Log(options.Testing, err)
		options.TestTearDown()
		assert.Empty(t, err, "This should not have errored")
		return
	}

	// we need to get all outputs to have access for a config output
	all_outputs, err := terraform.OutputAllE(options.Testing, options.TerraformOptions)
	if err != nil {
		logger.Log(options.Testing, err)
		options.TestTearDown()
		assert.Empty(t, err, "This should not have errored")
		return
	}

	// convert config to JSON string
	jsonStr, err := json.Marshal(all_outputs["config"])
	if err != nil {
		logger.Log(options.Testing, err)
		options.TestTearDown()
		assert.Empty(t, err, "This should not have errored")
		return
	}

	// set env variable with config value
	options.TerraformOptions.Vars["override_json_string"] = string(jsonStr)

	logger.Log(options.Testing, "Apply with override_json_string set")
	output, err := terraform.ApplyE(options.Testing, options.TerraformOptions)

	if err != nil {
		// we need to unset override_json_string terraform variable otherwise destroy fails
		options.TerraformOptions.Vars["override_json_string"] = ""
		options.TestTearDown()
		assert.Empty(t, err, "This should not have errored")
		return
	}

	// we need to unset override_json_string terraform variable otherwise destroy fails
	options.TerraformOptions.Vars["override_json_string"] = ""
	options.TestTearDown()

	logger.Log(options.Testing, "FINISHED: Init / Apply / Override Check")

	assert.Empty(t, err, "This should not have errored")
	assert.NotEmpty(t, output, "Expected some output")
}
