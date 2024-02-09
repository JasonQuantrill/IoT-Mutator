import os
import unittest
import subprocess

class TestSAC(unittest.TestCase):        
    base_folder = os.path.join('C:', os.sep, 'Users', 'jason', 'OneDrive', 'Documents', 'TMU', 'CPS40A', 'IoT-Mutator')
    test_prog = os.path.join(base_folder, 'SAC.txl')
    
    def test_Base(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'Base.rules')

        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    ItemA2.postUpdate (ON)\r\n'
                 'end\r\n'
                 '\r\n'
                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    ItemA2.sendCommand (OFF)\r\n'
                 'end\r\n'
                 '\r\n')
        
        self.assertEqual(test_result.stdout.decode(), actual_result)

    def test_SingleConditionSingleState(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionSingleState.rules')

        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    ItemA2.postUpdate (ON)\r\n'
                 'end\r\n'
                 '\r\n'
                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    ItemA2.sendCommand (OFF)\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)



if __name__ == '__main__':
    unittest.main()
