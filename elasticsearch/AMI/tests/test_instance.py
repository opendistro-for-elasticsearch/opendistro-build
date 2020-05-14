import os
import unittest
from unittest.mock import Mock, patch

from botocore.exceptions import ClientError, WaiterError

from lib.instance import Instance


class TestInstance(unittest.TestCase):
    @patch("lib.instance.boto3")
    @patch("lib.instance.Instance._create_key_pair")
    def setUp(self, create_key_pair, boto3_mock):
        """
        Initialise mock instance for the test cases
        """
        create_key_pair.return_value = "fakekey.pem"
        self.instance = Instance(
            AWS_access_key_id="1234",
            AWS_secret_access_key="1234",
            region_name="abc_region",
            base_image_id="ami-123",
            os="amazonLinux",
            security_group_id="sg-1234",
            AMI_name="OpenDistroAMI",
            RPM_package_version="1.0.0",
            APT_OSS_version="1.0.0",
        )
        self.boto_instance = boto3_mock.resource().create_instances()[
            0
        ]  # i could not figure out the any other way to mock boto3 instance
        self.instance.key_pair_name = "ODFEAMIInstanceKey"
        
    def test_initialization(self):
        """
        Fail with descriptive error if required initialization have failed
        """
        self.assertEqual("amazonLinux", self.instance.os)
        self.assertEqual("OpenDistroAMI", self.instance.AMI_name)
        self.assertEqual("1.0.0", self.instance.RPM_package_version)
        self.assertEqual("1.0.0", self.instance.APT_OSS_version)

    def test_incorrect_region(self):
        """
        Fail with descriptive error if Instance can be created for wrong region
        """
        with self.assertRaises(ValueError):
            Instance(
                region_name="wrong_region",
                AWS_access_key_id="1234",
                AWS_secret_access_key="1234",
                base_image_id="ami-123",
                os="amazonLinux",
                security_group_id="sg-1234",
                AMI_name="OpenDistroAMI",
                RPM_package_version="1.0.0",
                APT_OSS_version="1.0.0",
            )

    def test_incorrect_credentials(self):
        """
        Fail with descriptive error if Instance can be created with wrong credentials
        """
        with self.assertRaises(ClientError):
            Instance(
                AWS_access_key_id="wrong",
                AWS_secret_access_key="wrong",
                region_name="us-east-2",
                base_image_id="ami-123",
                os="amazonLinux",
                security_group_id="sg-1234",
                AMI_name="OpenDistroAMI",
                RPM_package_version="1.0.0",
                APT_OSS_version="1.0.0",
            )

    def test_wait_until_ready(self):
        """
        Exercises the code path for waiting until instance is ready to be used
        """
        self.boto_instance.wait_until_running.side_effect = [
            "",
            WaiterError("blah", "blah", "blah"),
        ]
        self.boto_instance.state = -1
        self.instance.wait_until_ready()
        self.boto_instance.wait_until_running.assert_called()
        self.assertRaises(WaiterError, self.instance.wait_until_ready)

    @patch("lib.instance.Instance.__init__")
    def test_create_key_pair(self, init_mock):
        """
        Exercises the code path for creating key pair
        """
        init_mock.return_value = None
        instance = Instance()
        instance.key_pair_name = self.instance.key_pair_name
        instance.ec2_client = Mock()
        instance.ec2_client.create_key_pair.return_value = {"KeyMaterial": "dummy key"}
        key_path = instance._create_key_pair()
        self.assertEquals(key_path, f"./{self.instance.key_pair_name}.pem")
        key = open(key_path, "r")
        self.assertEquals(key.read(), "dummy key")
        os.remove(f"./{self.instance.key_pair_name}.pem")

    def test_create_AMI(self):
        """
        Exercises the code path for creating AMI
        """
        self.boto_instance.create_image.return_value = Mock(image_id="123")
        self.instance.create_AMI()
        self.assertEquals(self.instance.snapshot.image_id, "123")
        self.instance.ec2_client.get_waiter().wait.side_effect = WaiterError("bla", "blah", "blah")
        self.assertRaises(WaiterError, self.instance.create_AMI)

    @patch("lib.instance.ODFEInstaller")
    def test_install_ODFE(self, mock_installer):
        """
        Exercises the code path for open distro installation in the instance
        """
        self.instance.install_ODFE()
        mock_installer().install.assert_called()
        mock_installer().install.side_effect = Exception
        self.assertRaises(Exception, self.instance.install_ODFE)

    def test_cleanup_instance(self):
        """
        Exercises the code path for cleaning up the instance after use
        """
        self.boto_instance.wait_until_terminated.side_effect = [
            "",
            WaiterError("blah", "blah", "blah"),
            "",
        ]
        temp = open(f"./{self.instance.key_pair_name}.pem", "w")
        self.instance.key_path = f"./{self.instance.key_pair_name}.pem"
        self.instance.cleanup_instance()
        self.boto_instance.wait_until_terminated.assert_called()
        temp = open(f"./{self.instance.key_pair_name}.pem", "w")
        self.assertRaises(WaiterError, self.instance.cleanup_instance)
        os.remove(f"./{self.instance.key_pair_name}.pem")
        self.assertRaises(FileNotFoundError, self.instance.cleanup_instance)


if __name__ == "__main__":
    unittest.main()