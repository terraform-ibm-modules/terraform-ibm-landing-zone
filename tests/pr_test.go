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

const quickstartExampleTerraformDir = "examples/quickstart"
const roksPatternTerraformDir = "patterns/roks"
const resourceGroup = "geretain-test-resources"

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

func TestRunRoksPattern2(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "r-no2")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// func TestRunRoksPatternPrintLogs(t *testing.T) {
// 	t.Parallel()
// 	// for testRunQuickstartExample == false && testRunUpgradeQuickstartExample == false && testRunRoksPattern == false && testRunRoksPattern2 == false {

// 	// 	fmt.Println("******* Logs not ready yet **********")
// 	// }
// 	time.Sleep(11000 * time.Second)
// 	fmt.Println("******* Store Logs to COS  **********")

// 	const (
// 		serviceInstanceID = "crn:v1:bluemix:public:cloud-object-storage:global:a/abac0df06b644a9cabc6e44f55b3880e:d58124a5-785d-46bd-b2c4-96cdcd4ec18b::"
// 		authEndpoint      = "https://iam.cloud.ibm.com/identity/token"
// 		serviceEndpoint   = "s3.eu-de.cloud-object-storage.appdomain.cloud"
// 	)
// 	apiKey := os.Getenv("TF_VAR_ibmcloud_api_key")
// 	conf := aws.NewConfig().
// 		WithEndpoint(serviceEndpoint).
// 		WithCredentials(ibmiam.NewStaticCredentials(aws.NewConfig(),
// 			authEndpoint, apiKey, serviceInstanceID)).
// 		WithS3ForcePathStyle(true)

// 	sess := session.Must(session.NewSession())
// 	client := s3.New(sess, conf)

// 	bucketName := "conall-49-cos-cos-standard-uja"
// 	key := "TF_logs_5.log"

// 	file, err := os.Open(complete)
// 	fmt.Println(err)

// 	defer file.Close()

// 	// content := bytes.NewReader([]byte(file))

// 	input := s3.PutObjectInput{
// 		Bucket: aws.String(bucketName),
// 		Key:    aws.String(key),
// 		Body:   file,
// 	}

// 	// Call Function to upload (Put) an object
// 	result, _ := client.PutObject(&input)
// 	fmt.Println(result)
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
