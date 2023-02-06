##############################################################################
# Proxy profiles
##############################################################################

output "with_json_access_logging" {
  description = "Turn on JSON access logging with fine compliant formatting"
  value = {
    accessLogging = {
      file = {
        encoding : "JSON"
        format : "[%START_TIME%] [%REQ(:AUTHORITY)%] [%BYTES_RECEIVED%] [%BYTES_SENT%] [%DOWNSTREAM_LOCAL_ADDRESS%] [%DOWNSTREAM_LOCAL_ADDRESS%] [%DOWNSTREAM_REMOTE_ADDRESS%] [%DOWNSTREAM_TLS_VERSION%] [%DURATION%] [%REQUEST_DURATION%] [%RESPONSE_DURATION%] [%RESPONSE_TX_DURATION%] [%DYNAMIC_METADATA(istio.mixer:status)%] [%REQ(:METHOD)%] [%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%] [%PROTOCOL%] [%REQ(X-REQUEST-ID)%] [%REQUESTED_SERVER_NAME%] [%RESPONSE_CODE%] [%RESPONSE_CODE_DETAILS%] [%RESPONSE_FLAGS%] [%ROUTE_NAME%] [%START_TIME%] [%UPSTREAM_CLUSTER%] [%UPSTREAM_HOST%] [%UPSTREAM_LOCAL_ADDRESS%] [%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%] [%UPSTREAM_TRANSPORT_FAILURE_REASON%] [%REQ(USER-AGENT)%] [%REQ(X-FORWARDED-FOR)%] [%REQ(X-ENVOY-ATTEMPT-COUNT)%]"
      }
    }
  }
}
