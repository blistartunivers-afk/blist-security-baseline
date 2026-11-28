import importlib.util
from pathlib import Path
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('installer', Path(__file__).with_name('install_baseline.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class InstallerTests(unittest.TestCase):
    def test_plan_and_apply_preserve_index_and_existing_work(self):
        source = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(['git', 'init', '-q', str(root)], check=True)
            (root/'work.txt').write_text('existing user work')
            subprocess.run(['git', '-C', str(root), 'add', 'work.txt'], check=True)
            before = subprocess.check_output(['git', '-C', str(root), 'diff', '--cached'])
            planned = module.install(source, root)
            self.assertTrue(planned)
            self.assertFalse((root/'.github').exists())
            module.install(source, root, apply=True)
            self.assertEqual(before, subprocess.check_output(['git', '-C', str(root), 'diff', '--cached']))
            target = root/'SECURITY.md'
            target.write_text('custom policy')
            with self.assertRaises(ValueError): module.install(source, root, apply=True)
            self.assertEqual(target.read_text(), 'custom policy')
            module.install(source, root, apply=True, overwrite=True)
            backups = list((root/'.blist-baseline-backups').rglob('SECURITY.md'))
            self.assertEqual(backups[0].read_text(), 'custom policy')
    def test_symlink_destination_refused(self):
        source = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)/'repo';root.mkdir()
            subprocess.run(['git', 'init', '-q', str(root)], check=True)
            (root/'SECURITY.md').symlink_to(Path(tmp)/'outside')
            with self.assertRaises(ValueError): module.install(source, root)

if __name__ == '__main__': unittest.main()
