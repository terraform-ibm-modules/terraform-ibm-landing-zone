package test

import (
	"fmt"
	"io/ioutil"
	"os"
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

var testRunQuickstartExample bool
var testRunUpgradeQuickstartExample bool
var testRunRoksPattern bool
var testRunRoksPattern2 bool
var logsSet = false
var complete string

func setLogs() {
	if logsSet == false {
		logsSet = true
		os.Setenv("TF_LOG", "trace")
		tempDir, err := ioutil.TempDir("", "terraform")
		fmt.Println(err)
		complete = tempDir + "/terraform.log"
		fmt.Println("logs path", complete)
		os.Setenv("TF_LOG_PATH", complete)
	}
}

func sshPublicKey(t *testing.T) string {
	setLogs()
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
	testRunQuickstartExample = false
	t.Parallel()

	options := setupOptionsQuickstart(t, "slz-qs")

	output, err := options.RunTestConsistency()
	testRunQuickstartExample = true
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeQuickstartExample(t *testing.T) {
	testRunUpgradeQuickstartExample = false
	t.Parallel()

	options := setupOptionsQuickstart(t, "slz-qs-ug")

	output, err := options.RunTestUpgrade()
	testRunUpgradeQuickstartExample = true
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
	testRunRoksPattern = false
	t.Parallel()

	options := setupOptionsRoksPattern(t, "r-no")

	output, err := options.RunTestConsistency()
	testRunRoksPattern = true
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunRoksPattern2(t *testing.T) {
	testRunRoksPattern2 = false
	t.Parallel()

	options := setupOptionsRoksPattern(t, "r-no2")

	output, err := options.RunTestConsistency()
	testRunRoksPattern2 = true
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// func TestRunRoksPatternPrintLogs(t *testing.T) {
// 	t.Parallel()
// 	for testRunQuickstartExample == false && testRunUpgradeQuickstartExample == false && testRunRoksPattern == false && testRunRoksPattern2 == false {
// 		time.Sleep(60 * time.Second)
// 		fmt.Println("******* Logs not ready yet **********")
// 	}

// 	fmt.Println("******* Print Logs **********")
// 	file, err := os.Open(complete)
// 	if err != nil {
// 		log.Fatal(err)
// 	}
// 	defer func() {
// 		if err = file.Close(); err != nil {
// 			log.Fatal(err)
// 		}
// 	}()

// 	scanner := bufio.NewScanner(file)

// 	for scanner.Scan() {
// 		fmt.Println(scanner.Text())
// 	}
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
