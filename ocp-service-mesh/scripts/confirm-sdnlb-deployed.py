#!/usr/bin/env python3

import json
import logging
import os
import subprocess
import sys
import time

KUBECONFIG = os.getenv("KUBECONFIG")

# debugging file init
DEBUGFILE = "/tmp/debug.log"
if os.path.exists(DEBUGFILE):
    os.remove(DEBUGFILE)

logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.FileHandler(DEBUGFILE)],
)


# if isError is true the output of the string is returned on sterr instead of stout
def returnMessage(message, isError=False):
    logging.info("returnResponse - response message " + message)
    if isError:
        print(message, file=sys.stderr)
    else:
        print(message)


NAMESPACE = sys.argv[1]
SVC_NAME = sys.argv[2]
STARTUP_SLEEP = 15
WAIT_BETWEEN_RETRIES = 30
RETRIES = 30  # 30 x 30 = 900 secs = 15 mins

fail = False

logging.info(f"KUBECONFIG: {KUBECONFIG}")
logging.info(f"Namespace: {NAMESPACE}")
logging.info(f"Service name: {SVC_NAME}")

logging.info(f"Sleeping for {STARTUP_SLEEP} seconds initially before going on")
time.sleep(STARTUP_SLEEP)
ingress = ""

for counter in range(RETRIES):

    if counter == (RETRIES - 1):
        # if attempts are over limit giving up
        logging.error(
            f"attempt {counter} reached max amount of retries {RETRIES} - giving up"
        )
        logging.error(
            f"ingress not ready for sdnlb svc {SVC_NAME} in namespace {NAMESPACE}"
        )
        # retrieving the svc details to return a useful message from svc describe events
        try:
            describe_content_cmd = subprocess.run(
                ["oc", "describe", "svc", "-n", NAMESPACE, SVC_NAME],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
            )
        except subprocess.CalledProcessError:
            emsg = f"error in describing svc {SVC_NAME} in namespace {NAMESPACE}"
            logging.error(emsg)
            returnMessage(emsg, True)
            exit(1)

        # retrieving events string
        events = describe_content_cmd.stdout.partition("Events:")
        logging.error(events[2])
        mainerror = f"ingress not ready for sdnlb svc {SVC_NAME} in namespace {NAMESPACE} after {RETRIES} retries"
        emsg = ""
        if not events:
            emsg = f"{mainerror} - Unable to retrieve events for sdnlb svc {SVC_NAME} in namespace {NAMESPACE}"
        else:
            emsg = f"{mainerror} - Events from sdnlb svc {SVC_NAME} in namespace {NAMESPACE}: {events[2]}"

        logging.error(emsg)
        returnMessage(emsg, True)
        exit(1)

    # Getting status of sdnlb LB
    logging.info("Retrieving svc " + SVC_NAME + " status in namespace " + NAMESPACE)
    try:
        oc_result = subprocess.run(
            ["oc", "get", "svc", "-n", NAMESPACE, SVC_NAME, "-o", "json"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
    except subprocess.CalledProcessError:
        emsg = f"error in getting svc {SVC_NAME} in namespace {NAMESPACE}"
        logging.error(emsg)
        returnMessage(emsg, True)
        exit(1)

    logging.debug(oc_result.stdout)
    service_status = json.loads(oc_result.stdout)
    load_balancer = service_status["status"]["loadBalancer"]
    ingress = load_balancer.get("ingress", "")
    logging.info(f"Ingress: {ingress}")

    # if ingress is empty the sdnlb IPs are not assigned yet
    msg = ""
    if ingress != "":
        msg = f"ingress ready for sdnlb svc {SVC_NAME} in namespace {NAMESPACE} at attempt {counter}"
        logging.info(msg)
        returnMessage(msg)
        break
    msg = f"ingress not ready for sdnlb svc {SVC_NAME} in namespace {NAMESPACE} "
    msg = msg + f"at attempt {counter} - sleeping for {WAIT_BETWEEN_RETRIES} seconds "
    logging.info(msg)
    returnMessage(msg)
    time.sleep(WAIT_BETWEEN_RETRIES)

logging.info("INGRESS seems to be configured - retrieving IPs")
ips = ""
for ip in ingress:
    if not ips:
        ips = ip["ip"]
    else:
        ips += f" {ip['ip']}"

msg = f"sdnlb svc {SVC_NAME} namespace {NAMESPACE} IPs: {ips}"
logging.info(f"sdnlb svc {SVC_NAME} namespace {NAMESPACE} IPs: {ips}")
returnMessage(msg)
