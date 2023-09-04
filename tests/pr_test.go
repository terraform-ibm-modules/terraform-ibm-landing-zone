package test

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"

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

func TestRunQuickStartPattern(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := setupOptionsQuickStartPattern(t, "vsi-qs", quickStartPatternTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeQuickStartPattern(t *testing.T) {
	t.Skip()
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

func TestRunRoksPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsRoksPattern(t, "ocp")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeRoksPattern(t *testing.T) {
	t.Skip()
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
	t.Skip()
	t.Parallel()

	options := setupOptionsVsiPattern(t, "vsi-u")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunVSIPattern(t *testing.T) {
	t.Parallel()

	options := setupOptionsVsiPattern(t, "vsi")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
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

func TestRunVpcPattern(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := setupOptionsVpcPattern(t, "vpc")

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeVpcPattern(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := setupOptionsVpcPattern(t, "vpc-ug")

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

// terraform apply -var=prefix=vsi-s-andrej -var=region=eu-de -var=ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
func TestRunOverride(t *testing.T) {
	// t.Skip()
	t.Parallel()

	options := setupOptionsQuickStartPattern(t, "slz-qs", quickStartPatternTerraformDir)
	options.SkipTestTearDown = true
	output, err := options.RunTestConsistency()

	outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)

	jsonStr, err := json.Marshal(outputs["config"])

	options.TerraformOptions.Vars["override_json_string"] = "{\n    \"access_groups\": [],\n    \"add_kms_block_storage_s2s\": true,\n    \"appid\": {\n        \"keys\": [\n            \"slz-appid-key\"\n        ],\n        \"name\": \"appid\",\n        \"resource_group\": \"slz-qs-pj2wz9-service-rg\",\n        \"use_appid\": true,\n        \"use_data\": false\n    },\n    \"atracker\": {\n        \"add_route\": false,\n        \"collector_bucket_name\": \"\",\n        \"receive_global_events\": false,\n        \"resource_group\": \"\"\n    },\n    \"clusters\": [],\n    \"cos\": [],\n    \"enable_transit_gateway\": true,\n    \"f5_template_data\": {\n        \"app_id\": \"null\",\n        \"as3_declaration_url\": \"null\",\n        \"byol_license_basekey\": null,\n        \"do_declaration_url\": \"null\",\n        \"license_host\": null,\n        \"license_password\": null,\n        \"license_pool\": null,\n        \"license_sku_keyword_1\": null,\n        \"license_sku_keyword_2\": null,\n        \"license_type\": \"none\",\n        \"license_unit_of_measure\": \"hourly\",\n        \"license_username\": null,\n        \"phone_home_url\": \"null\",\n        \"template_source\": \"f5devcentral/ibmcloud_schematics_bigip_multinic_declared\",\n        \"template_version\": \"20210201\",\n        \"tgactive_url\": \"\",\n        \"tgrefresh_url\": \"null\",\n        \"tgstandby_url\": \"null\",\n        \"tmos_admin_password\": null,\n        \"ts_declaration_url\": \"null\"\n    },\n    \"f5_vsi\": [],\n    \"iam_account_settings\": {\n        \"enable\": false\n    },\n    \"key_management\": {\n        \"keys\": [\n            {\n                \"key_ring\": \"slz-ring\",\n                \"name\": \"slz-vsi-volume-key\",\n                \"policies\": {\n                    \"rotation\": {\n                        \"interval_month\": 12\n                    }\n                },\n                \"root_key\": true\n            }\n        ],\n        \"name\": \"slz-kms\",\n        \"resource_group\": \"service-rg\",\n        \"use_data\": false,\n        \"use_hs_crypto\": false\n    },\n    \"network_cidr\": \"10.0.0.0/8\",\n    \"resource_groups\": [\n        {\n            \"create\": true,\n            \"name\": \"service-rg\",\n            \"use_prefix\": true\n        },\n        {\n            \"create\": true,\n            \"name\": \"management-rg\",\n            \"use_prefix\": true\n        },\n        {\n            \"create\": true,\n            \"name\": \"workload-rg\",\n            \"use_prefix\": true\n        }\n    ],\n    \"secrets_manager\": {\n        \"kms_key_name\": null,\n        \"name\": null,\n        \"resource_group\": null,\n        \"use_secrets_manager\": false\n    },\n    \"security_groups\": [],\n    \"service_endpoints\": \"private\",\n    \"ssh_keys\": [\n        {\n            \"name\": \"ssh-key\",\n            \"public_key\": \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTOjamJGTgZXM2uiFbwgOE++2I9E5rnpv/ITm+JCRMRBpyn7WSB5t/xIMkzO88M4G3dJC9ZUZFpHnM124kacijHgVL/zncn74pe6CZPscCjyXFuF/JIB/qDPGiEl9sVdtaxuv2oc9D1HIS5zpUFtLnmwpajlVZPz5H1v9++T4AI+LQBuVeIipq4c2eBimORyI8rVAohA966y4xUjG3GVhwmhCJMzscliDiopOLmLBSr/PCR3X5Wyt2uafrD6/L5wq5DW4jSFEALtcBNo3MJxzj0BC8PD7d/zjGUcjptt6Mv2IxT6Q0Wfmbrd4UjLr6lDfegZvl+2yB/LZ62mcczzd9LuCkHA28+mx8waS6G96L/BYUI1i1kCqYDy4TluWhgmHvjonRRjpPC+qU4uPfHxEIkma7/6ExWuNN9eCVybHb0JhUzWmBt7j+I2664xdNXpSC1v3bRlcrOtxVUo9CYw00a4UlfrW4FsxJe0Kpjri/Y1//deQCpLhuVZJ7Pjj+r8e8dRv6zx08E0WzNdrpqEZiWw0Y8xbMMCxuBKVJnhB4YTO6sC9gMhPrVtrjxo2iNlMK4cnFjujbf4r2rgEGihnADdgcGOkK94QppQds7DXcr1MBCyGHq8OXky0C91k43RbtTC0VI076RavNA5QvFx9CPn19aBq4IJ/aViQL1wkwQw==\"\n        }\n    ],\n    \"teleport_config\": {\n        \"app_id_key_name\": \"slz-appid-key\",\n        \"claims_to_roles\": [\n            {\n                \"email\": null,\n                \"roles\": [\n                    \"teleport-admin\"\n                ]\n            }\n        ],\n        \"cos_bucket_name\": \"bastion-bucket\",\n        \"cos_key_name\": \"bastion-key\",\n        \"domain\": null,\n        \"hostname\": null,\n        \"https_cert\": null,\n        \"https_key\": null,\n        \"message_of_the_day\": null,\n        \"teleport_license\": null,\n        \"teleport_version\": \"7.1.0\"\n    },\n    \"teleport_vsi\": [],\n    \"transit_gateway_connections\": [\n        \"management\",\n        \"workload\"\n    ],\n    \"transit_gateway_resource_group\": \"service-rg\",\n    \"virtual_private_endpoints\": [],\n    \"vpc_placement_groups\": [],\n    \"vpcs\": [\n        {\n            \"address_prefixes\": {\n                \"zone-1\": [],\n                \"zone-2\": [],\n                \"zone-3\": []\n            },\n            \"clean_default_acl\": true,\n            \"clean_default_security_group\": true,\n            \"flow_logs_bucket_name\": null,\n            \"network_acls\": [\n                {\n                    \"add_cluster_rules\": false,\n                    \"name\": \"management-acl\",\n                    \"rules\": [\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"10.0.0.0/8\",\n                            \"direction\": \"inbound\",\n                            \"name\": \"allow-ssh-inbound\",\n                            \"source\": \"0.0.0.0/0\",\n                            \"tcp\": {\n                                \"port_max\": 22,\n                                \"port_min\": 22\n                            }\n                        },\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"10.0.0.0/8\",\n                            \"direction\": \"inbound\",\n                            \"name\": \"allow-ibm-inbound\",\n                            \"source\": \"161.26.0.0/16\"\n                        },\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"10.0.0.0/8\",\n                            \"direction\": \"inbound\",\n                            \"name\": \"allow-all-network-inbound\",\n                            \"source\": \"10.0.0.0/8\"\n                        },\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"0.0.0.0/0\",\n                            \"direction\": \"outbound\",\n                            \"name\": \"allow-all-outbound\",\n                            \"source\": \"0.0.0.0/0\"\n                        }\n                    ]\n                }\n            ],\n            \"prefix\": \"testm\",\n            \"resource_group\": \"management-rg\",\n            \"subnets\": {\n                \"zone-1\": [\n                    {\n                        \"acl_name\": \"management-acl\",\n                        \"cidr\": \"10.10.10.0/24\",\n                        \"name\": \"vsi-zone-1\",\n                        \"public_gateway\": false\n                    }\n                ],\n                \"zone-2\": [],\n                \"zone-3\": []\n            },\n            \"use_public_gateways\": {\n                \"zone-1\": false,\n                \"zone-2\": false,\n                \"zone-3\": false\n            }\n        },\n        {\n            \"address_prefixes\": {\n                \"zone-1\": [],\n                \"zone-2\": [],\n                \"zone-3\": []\n            },\n            \"clean_default_acl\": true,\n            \"clean_default_security_group\": true,\n            \"flow_logs_bucket_name\": null,\n            \"network_acls\": [\n                {\n                    \"add_cluster_rules\": false,\n                    \"name\": \"workload-acl\",\n                    \"rules\": [\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"10.0.0.0/8\",\n                            \"direction\": \"inbound\",\n                            \"name\": \"allow-ibm-inbound\",\n                            \"source\": \"161.26.0.0/16\"\n                        },\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"10.0.0.0/8\",\n                            \"direction\": \"inbound\",\n                            \"name\": \"allow-all-network-inbound\",\n                            \"source\": \"10.0.0.0/8\"\n                        },\n                        {\n                            \"action\": \"allow\",\n                            \"destination\": \"0.0.0.0/0\",\n                            \"direction\": \"outbound\",\n                            \"name\": \"allow-all-outbound\",\n                            \"source\": \"0.0.0.0/0\"\n                        }\n                    ]\n                }\n            ],\n            \"prefix\": \"workload\",\n            \"resource_group\": \"workload-rg\",\n            \"subnets\": {\n                \"zone-1\": [\n                    {\n                        \"acl_name\": \"workload-acl\",\n                        \"cidr\": \"10.40.10.0/24\",\n                        \"name\": \"vsi-zone-1\",\n                        \"public_gateway\": false\n                    }\n                ],\n                \"zone-2\": [],\n                \"zone-3\": []\n            },\n            \"use_public_gateways\": {\n                \"zone-1\": false,\n                \"zone-2\": false,\n                \"zone-3\": false\n            }\n        }\n    ],\n    \"vpn_gateways\": [],\n    \"vsi\": [\n        {\n            \"boot_volume_encryption_key_name\": \"slz-vsi-volume-key\",\n            \"enable_floating_ip\": true,\n            \"image_name\": \"ibm-ubuntu-22-04-2-minimal-amd64-1\",\n            \"machine_type\": \"cx2-4x8\",\n            \"name\": \"jump-box\",\n            \"resource_group\": \"management-rg\",\n            \"security_group\": {\n                \"name\": \"management\",\n                \"rules\": [\n                    {\n                        \"direction\": \"inbound\",\n                        \"name\": \"allow-ssh-inbound\",\n                        \"source\": \"0.0.0.0/0\",\n                        \"tcp\": {\n                            \"port_max\": 22,\n                            \"port_min\": 22\n                        }\n                    },\n                    {\n                        \"direction\": \"inbound\",\n                        \"name\": \"allow-ibm-inbound\",\n                        \"source\": \"161.26.0.0/16\"\n                    },\n                    {\n                        \"direction\": \"inbound\",\n                        \"name\": \"allow-vpc-inbound\",\n                        \"source\": \"10.0.0.0/8\"\n                    },\n                    {\n                        \"direction\": \"outbound\",\n                        \"name\": \"allow-all-outbound\",\n                        \"source\": \"0.0.0.0/0\"\n                    }\n                ]\n            },\n            \"ssh_keys\": [\n                \"ssh-key\"\n            ],\n            \"subnet_names\": [\n                \"vsi-zone-1\"\n            ],\n            \"vpc_name\": \"management\",\n            \"vsi_per_subnet\": 1\n        },\n        {\n            \"boot_volume_encryption_key_name\": \"slz-vsi-volume-key\",\n            \"enable_floating_ip\": false,\n            \"image_name\": \"ibm-ubuntu-22-04-2-minimal-amd64-1\",\n            \"machine_type\": \"cx2-4x8\",\n            \"name\": \"workload-server\",\n            \"resource_group\": \"workload-rg\",\n            \"security_group\": {\n                \"name\": \"workload\",\n                \"rules\": [\n                    {\n                        \"direction\": \"inbound\",\n                        \"name\": \"allow-ibm-inbound\",\n                        \"source\": \"161.26.0.0/16\"\n                    },\n                    {\n                        \"direction\": \"inbound\",\n                        \"name\": \"allow-vpc-inbound\",\n                        \"source\": \"10.0.0.0/8\"\n                    },\n                    {\n                        \"direction\": \"outbound\",\n                        \"name\": \"allow-all-outbound\",\n                        \"source\": \"0.0.0.0/0\"\n                    }\n                ]\n            },\n            \"ssh_keys\": [\n                \"ssh-key\"\n            ],\n            \"subnet_names\": [\n                \"vsi-zone-1\"\n            ],\n            \"vpc_name\": \"workload\",\n            \"vsi_per_subnet\": 1\n        }\n    ],\n    \"wait_till\": \"IngressReady\"\n}"

	output2, err := terraform.ApplyE(options.Testing, options.TerraformOptions)

	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
	// we need to unset override_json_string terraform variable otherwise destroy fails
	options.TerraformOptions.Vars["override_json_string"] = ""
	options.TestTearDown()
}
