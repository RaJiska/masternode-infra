import subprocess
import logging
import json
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def run_command(command):
    command_joined = ' '.join([str(i) for i in command])
    try:
        logger.info("Running shell command: \"{}\"".format(command_joined))
        print(command_joined)
        result = subprocess.run(command, stderr=subprocess.STDOUT, stdout=subprocess.PIPE);
        logger.info("Command output:\n---\n{}\n---".format(result.stdout.decode('UTF-8')))
    except Exception as e:
        logger.error("Command could not be executed: {}".format(e))
        raise e
    return result

def lambda_handler(event, context):
  """
  Update the launch template passed as environment variable with the snapshot ID passed in `event`

  :param event: array of snapshot ID, use only the first array
  :param context: context of the lambda
  """
  logger.info("Updating launch template")
  result = run_command(["/opt/aws", "ec2", "describe-launch-templates", "--launch-template-id", str(os.environ.get("LAUNCH_TEMPLATE_ID"))])
  ltVersion = json.loads(result.stdout.decode('UTF-8'))["LaunchTemplates"][0]["LatestVersionNumber"]
  result = run_command(["/opt/aws", "ec2", "describe-launch-template-versions", "--launch-template-id", str(os.environ.get("LAUNCH_TEMPLATE_ID")), "--versions", str(ltVersion)])
  ltData = json.loads(result.stdout.decode('UTF-8'))["LaunchTemplateVersions"][0]["LaunchTemplateData"]
  updatableVolumeIdx = [idx for idx, i in enumerate(ltData["BlockDeviceMappings"]) if i["DeviceName"] in ["/dev/sdb", "/dev/xvdb"]][0]
  ltData["BlockDeviceMappings"][updatableVolumeIdx]["Ebs"]["SnapshotId"] = event[0]
  result = run_command(["/opt/aws", "ec2", "create-launch-template-version", "--launch-template-id", str(os.environ.get("LAUNCH_TEMPLATE_ID")), "--source-version", str(ltVersion), "--launch-template-data", json.dumps(ltData)])
