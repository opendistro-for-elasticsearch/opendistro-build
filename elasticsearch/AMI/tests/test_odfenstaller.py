import unittest
from unittest.mock import MagicMock, Mock, patch

from paramiko import SSHException

from lib.ODFEInstaller import ODFEInstaller


class TestInstaller(unittest.TestCase):
    @patch("lib.ODFEInstaller.paramiko")
    def setUp(self, mock_paramiko):
        """
        Initialise mock Installer for the test cases
        """
        self.installer = ODFEInstaller(
            "ec2.amazon.com", "ec2", "ubuntu", "./ODFEAMIInstanceKey.pem", "1.4.0", "7.4.2"
        )

    def test_initialization(self):
        """
        Fail with descriptive error if required initialization have failed
        """
        self.assertEqual(self.installer.host_name, "ec2.amazon.com")
        self.assertEqual(self.installer.user_name, "ec2")
        self.assertEqual(self.installer.os, "ubuntu")
        self.assertEqual(self.installer.key_path, "./ODFEAMIInstanceKey.pem")
        self.assertEqual(self.installer.RPM_package_version, "1.4.0")
        self.assertEqual(self.installer.APT_OSS_version, "7.4.2")

    @patch("lib.ODFEInstaller.paramiko")
    def test_get_SSH_client(self, mock_paramiko):
        """
        Exercises the code path for getting SSH client
        """
        _mock = Mock()
        mock_paramiko.SSHClient.return_value = _mock
        client = self.installer._get_SSH_client()
        self.assertEqual(_mock.name, client.name)
        mock_paramiko.RSAKey.from_private_key_file.side_effect = FileNotFoundError
        with self.assertRaises(FileNotFoundError):
            self.installer._get_SSH_client()

    @patch("lib.ODFEInstaller.paramiko")
    def test_run_command(self, mock_paramiko):
        """
        Exercises the code path for running the command on instance
        """
        _mock = Mock()
        self.installer.SSH_client.exec_command.return_value = [_mock, "output123", "error"]
        stdout, stderr = self.installer._run_command("description", "command")
        self.assertEqual("output123", stdout)
        self.installer.SSH_client.exec_command.side_effect = SSHException
        with self.assertRaises(SSHException):
            self.installer._run_command("description", "command")

    def test_get_commands(self):
        """
        Exercises the code path for getting the installation commands
        """
        self.installer.os = "amazonLinux"
        commands = self.installer._get_commands()
        assert len(commands) > 0
        self.installer.os = "ubuntu"
        commands = self.installer._get_commands()
        assert len(commands) > 0
        self.installer.os = "does_not_exist"
        commands = self.installer._get_commands()
        self.assertEqual(len(commands), 1)

    def test_install(self):
        """
        Exercises the code path for installing opendistro on the instance
        """
        self.installer._run_command = Mock()
        self.installer._pretty_print = Mock()
        self.installer.verify_installation = Mock()
        stdout = Mock()
        stderr = Mock()
        self.installer._run_command.return_value = (stdout, stderr)
        stdout.channel.recv_exit_status.return_value = 0
        self.installer.verify_installation.return_value = "Success"
        self.installer.install()
        # self.installer.verify_installation.return_value = "Fail"
        # with self.assertRaises(Exception):
        #     self.installer.install()
        self.installer.verify_installation.return_value = "Success"
        stdout.channel.recv_exit_status.return_value = -1
        with self.assertRaises(Exception):
            self.installer.install()
        self.installer._run_command.side_effect = SSHException
        with self.assertRaises(SSHException):
            self.installer.install()

    def test_verify_installation(self):
        """
        Exercises the code path for verifying installation of opendistro on the instance
        """
        self.installer._pretty_print = Mock()
        self.installer._run_command = Mock()
        stdout = Mock()
        stderr = Mock()
        self.installer._run_command.return_value = (stdout, stderr)
        stderr.read().splitlines.return_value = []
        self.assertEqual("Success", self.installer.verify_installation())
        stderr.read().splitlines.return_value = ["error"]
        self.assertEqual("Fail", self.installer.verify_installation())


if __name__ == "__main__":
    unittest.main()