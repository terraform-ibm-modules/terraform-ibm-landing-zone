package test

import (
	"encoding/json"
	"fmt"
	tfjson "github.com/hashicorp/terraform-json"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const quickStartPatternTerraformDir = "patterns/vsi-quickstart"
const roksPatternTerraformDir = "patterns/roks"
const vsiPatternTerraformDir = "patterns/vsi"
const vpcPatternTerraformDir = "patterns/vpc"
const resourceGroup = "geretain-test-resources"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

// Setting "add_atracker_route" to false for VPC and VSI tests to avoid hitting AT route quota, right now its 4 routes per account.
const add_atracker_route = false

var sharedInfoSvc *cloudinfo.CloudInfoService
var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to set up a shared InfoService object to track region usage
// for multiple tests
func TestMain(m *testing.M) {
	sharedInfoSvc, _ = cloudinfo.NewCloudInfoServiceFromEnv("TF_VAR_ibmcloud_api_key", cloudinfo.CloudInfoServiceOptions{})

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func sshPublicKey(t *testing.T) string {
	pubKey, keyErr := common.GenerateSshRsaPublicKey()

	// if error producing key (very unexpected) fail test immediately
	require.NoError(t, keyErr, "SSH Keygen failed, without public ssh key test cannot continue")

	return pubKey
}

func setupOptionsQuickStartPattern(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		TerraformVars: map[string]interface{}{
			"ssh_key": sshPublicKey,
		},
		CloudInfoService: sharedInfoSvc,
	})

	return options
}

type tarIncludePatterns struct {
	excludeDirs []string

	includeFiletypes []string

	includeDirs []string
}

func getTarIncludePatternsRecursively(dir string, dirsToExclude []string, fileTypesToInclude []string) ([]string, error) {
	r := tarIncludePatterns{dirsToExclude, fileTypesToInclude, nil}
	err := filepath.WalkDir(dir, func(path string, entry fs.DirEntry, err error) error {
		return walk(&r, path, entry, err)
	})
	if err != nil {
		fmt.Println("error")
		return r.includeDirs, err
	}
	return r.includeDirs, nil
}

func walk(r *tarIncludePatterns, s string, d fs.DirEntry, err error) error {
	if err != nil {
		return err
	}
	if d.IsDir() {
		for _, excludeDir := range r.excludeDirs {
			if strings.Contains(s, excludeDir) {
				return nil
			}
		}
		if s == ".." {
			r.includeDirs = append(r.includeDirs, "*.tf")
			return nil
		}
		for _, includeFiletype := range r.includeFiletypes {
			r.includeDirs = append(r.includeDirs, strings.ReplaceAll(s+"/*"+includeFiletype, "../", ""))
		}
	}
	return nil
}

func TestRunUpgradeQuickStartPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickStartPattern(t, "vsi-qs-u", quickStartPatternTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsRoksPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     roksPatternTerraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"prefix": options.Prefix,
		"tags":   options.Tags,
		"region": options.Region,
	}

	return options
}

func TestRunUpgradeRoksPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "ocp-u")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsVsiPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	sshPublicKey := sshPublicKey(t)

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     vsiPatternTerraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"ssh_public_key":     sshPublicKey,
		"prefix":             options.Prefix,
		"tags":               options.Tags,
		"region":             options.Region,
		"add_atracker_route": add_atracker_route,
	}

	return options
}

func TestRunUpgradeVsiPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVsiPattern(t, "vsi-u")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func setupOptionsVpcPattern(t *testing.T, prefix string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:          t,
		TerraformDir:     vpcPatternTerraformDir,
		Prefix:           prefix,
		ResourceGroup:    resourceGroup,
		CloudInfoService: sharedInfoSvc,
	})

	options.TerraformVars = map[string]interface{}{
		"prefix":             options.Prefix,
		"tags":               options.Tags,
		"region":             options.Region,
		"add_atracker_route": add_atracker_route,
	}

	return options
}

func TestRunUpgradeVpcPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVpcPattern(t, "vpc-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

// sanitizeResourceChanges sanitizes the sensitive data in a Terraform JSON Change and returns the sanitized JSON.
func sanitizeResourceChanges(change *tfjson.Change, mergedSensitive map[string]interface{}) (string, error) {
	// Marshal the Change to JSON bytes
	changesBytes, err := json.MarshalIndent(change, "", "  ")
	if err != nil {
		return "", err
	}
	changesJson := string(changesBytes)

	// Perform sanitization of sensitive data
	changesJson, err = common.SanitizeSensitiveData(changesJson, mergedSensitive)
	return changesJson, err
}

// handleSanitizationError logs an error message if a sanitization error occurs.
func handleSanitizationError(err error, location string, options *testhelper.TestOptions) {
	if err != nil {
		errorMessage := fmt.Sprintf("Error sanitizing sensitive data in %s", location)
		logger.Log(options.Testing, errorMessage)
	}
}

func TestRunOverride(t *testing.T) {
	t.Parallel()

	options := setupOptionsQuickStartPattern(t, "slz-ovr", quickStartPatternTerraformDir)
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

			// defines if at least one resource changed (destroy, update, etc)
			resourcesChanged := false
			for _, resource := range planStruct.ResourceChangesMap {
				// get JSON string of full changes for the logs
				changesBytes, changesErr := json.MarshalIndent(resource.Change, "", "  ")
				// if it errors in the marshall step, just put a placeholder and move on, not important
				changesJson := "--UNAVAILABLE--"
				if changesErr == nil {
					changesJson = string(changesBytes)
				}

				var resourceDetails string

				// Treat all keys in the BeforeSensitive and AfterSensitive maps as sensitive
				// Assuming BeforeSensitive and AfterSensitive are of type interface{}
				beforeSensitive, beforeSensitiveOK := resource.Change.BeforeSensitive.(map[string]interface{})
				afterSensitive, afterSensitiveOK := resource.Change.AfterSensitive.(map[string]interface{})

				// Create the mergedSensitive map
				mergedSensitive := make(map[string]interface{})

				// Check if BeforeSensitive is of the expected type
				if beforeSensitiveOK {
					// Copy the keys and values from BeforeSensitive to the mergedSensitive map.
					for key, value := range beforeSensitive {
						mergedSensitive[key] = value
					}
				}

				// Check if AfterSensitive is of the expected type
				if afterSensitiveOK {
					// Copy the keys and values from AfterSensitive to the mergedSensitive map.
					for key, value := range afterSensitive {
						mergedSensitive[key] = value
					}
				}

				// Perform sanitization
				changesJson, err := sanitizeResourceChanges(resource.Change, mergedSensitive)
				if err != nil {
					changesJson = "Error sanitizing sensitive data"
					logger.Log(options.Testing, changesJson)
				}
				formatChangesJson, err := common.FormatJsonStringPretty(changesJson)

				var formatChangesJsonString string
				if err != nil {
					logger.Log(options.Testing, "Error formatting JSON, use unformatted")
					formatChangesJsonString = changesJson
				} else {
					formatChangesJsonString = string(formatChangesJson)
				}

				diff, diffErr := common.GetBeforeAfterDiff(changesJson)

				if diffErr != nil {
					diff = fmt.Sprintf("Error getting diff: %s", diffErr)
				} else {
					// Split the changesJson into "Before" and "After" parts
					beforeAfter := strings.Split(diff, "After: ")

					// Perform sanitization on "After" part
					var after string
					if len(beforeAfter) > 1 {
						after, err = common.SanitizeSensitiveData(beforeAfter[1], mergedSensitive)
						handleSanitizationError(err, "after diff", options)
					} else {
						after = fmt.Sprintf("Could not parse after from diff") // dont print incase diff contains sensitive values
					}

					// Perform sanitization on "Before" part
					var before string
					if len(beforeAfter) > 0 {
						before, err = common.SanitizeSensitiveData(strings.TrimPrefix(beforeAfter[0], "Before: "), mergedSensitive)
						handleSanitizationError(err, "before diff", options)
					} else {
						before = fmt.Sprintf("Could not parse before from diff") // dont print incase diff contains sensitive values
					}

					// Reassemble the sanitized diff string
					diff = "  Before: \n\t" + before + "\n  After: \n\t" + after
				}
				resourceDetails = fmt.Sprintf("\nName: %s\nAddress: %s\nActions: %s\nDIFF:\n%s\n\nChange Detail:\n%s", resource.Name, resource.Address, resource.Change.Actions, diff, formatChangesJsonString)

				// build error message
				var errorMessage string
				errorMessage = fmt.Sprintf("Resource(s) identified to be destroyed %s", resourceDetails)

				// check if current resource is changed
				noResourceChange := resource.Change.Actions.NoOp() || resource.Change.Actions.Read()
				assert.True(options.Testing, noResourceChange, errorMessage)

				// if at least one resource is changed, then save that information
				if !resourcesChanged && !noResourceChange {
					resourcesChanged = true
				}
			}

			// Run plan again to output the nice human-readable plan if there was a change
			if resourcesChanged {
				terraform.Plan(options.Testing, options.TerraformOptions)
			}
		}
	}
	options.TestTearDown()
}

func setupOptionsSchematics(t *testing.T, prefix string, dir string) *testschematic.TestSchematicOptions {

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
		TemplateFolder:         dir,
		Prefix:                 "ocp-sc",
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		CloudInfoService:       sharedInfoSvc,
	})

	return options
}

func TestRunVSIQuickStartPatternSchematics(t *testing.T) {
	t.Parallel()

	options := setupOptionsSchematics(t, "qs-sc", quickStartPatternTerraformDir)

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

	options := setupOptionsSchematics(t, "vsi-sc", vsiPatternTerraformDir)

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "ssh_public_key", Value: sshPublicKey(t), DataType: "string"},
		{Name: "add_atracker_route", Value: add_atracker_route, DataType: "bool"},
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
	}

	err := options.RunSchematicTest()
	assert.NoError(t, err, "Schematic Test had unexpected error")
}
