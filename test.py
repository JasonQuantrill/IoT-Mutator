import os
import unittest
import subprocess

# class TestWAC(unittest.TestCase):        
#     base_folder = os.path.join('C:', os.sep, 'Users', 'jason', 'OneDrive', 'Documents', 'TMU', 'CPS40A', 'IoT-Mutator')
#     test_prog = os.path.join(base_folder, 'WAC.txl')
    
#     def test_Base(self):
#         test_case = os.path.join(self.base_folder, 'testsuite', 'Base.rules')

#         test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        
#         actual_result = (
#                  'rule "Rule A"\r\n'
#                  'when\r\n'
#                  '    Item ItemA1 changed to ON\r\n'
#                  'then\r\n'
#                  'if (ConditionA1 && ConditionA2)\r\n'
#                 '{\r\n'
#                       'logInfo ("ItemA2", "Turning On")\r\n'
#                       'ItemA2.postUpdate (ON)\r\n'
#                 '}\r\n'
#                  '    ItemA2.postUpdate (ON)\r\n'
#                  'end\r\n'
#                  '\r\n'
#                  'rule "Rule B"\r\n'
#                  'when\r\n'
#                  '    Item ItemA1 changed to ON\r\n'
#                  'then\r\n'
#                  '    ItemA2.sendCommand (OFF)\r\n'
#                  'end\r\n'
#                  '\r\n')
        
#         self.assertEqual(test_result.stdout.decode(), actual_result)

#     def test_SingleConditionSingleState(self):
#         test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionSingleState.rules')

#         test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
#         actual_result = (
#                  'rule "Rule A"\r\n'
#                  'when\r\n'
#                  '    Item ItemA1 changed to ON\r\n'
#                  'then\r\n'
#                  '    ItemA2.postUpdate (ON)\r\n'
#                  'end\r\n'
#                  '\r\n'
#                  'rule "Rule B"\r\n'
#                  'when\r\n'
#                  '    Item ItemA1 changed to ON\r\n'
#                  'then\r\n'
#                  '    ItemA2.sendCommand (OFF)\r\n'
#                  'end\r\n'
#                  '\r\n')

#         self.assertEqual(test_result.stdout.decode(), actual_result)

#     def test_SingleConditionMultiState(self):
#         test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionMultiStates.rules')
        
#         test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
#         actual_result = (
#                  'rule "Rule A"\r\n'
#                  'when\r\n'
#                  '    Item ItemA1 changed to ON\r\n'
#                  'then\r\n'
#                  '    logInfo ("ItemA2", "Turning On")\r\n'
#                  '    ItemA2.postUpdate (ON)\r\n'
#                  'end\r\n'
#                  '\r\n'
#                  'rule "Rule B"\r\n'
#                  'when\r\n'
#                  '    Item ItemA1 changed to ON\r\n'
#                  'then\r\n'
#                  '    logInfo ("ItemB2", "Turning On")\r\n'
#                  '    ItemA2.sendCommand (OFF)\r\n'
#                  'end\r\n'
#                  '\r\n')

#         self.assertEqual(test_result.stdout.decode(), actual_result)

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

    def test_SingleConditionMultiState(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionMultiStates.rules')
        
        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    logInfo ("ItemA2", "Turning On")\r\n'
                 '    ItemA2.postUpdate (ON)\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    logInfo ("ItemB2", "Turning On")\r\n'
                 '    ItemA2.sendCommand (OFF)\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)

class TestWTCA(unittest.TestCase):        
    base_folder = os.path.join('C:', os.sep, 'Users', 'jason', 'OneDrive', 'Documents', 'TMU', 'CPS40A', 'IoT-Mutator')
    test_prog = os.path.join(base_folder, 'WTC-A.txl')
    
    def test_Base(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'Base.rules')

        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    ItemB1.postUpdate (OFF)\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    ItemB2.sendCommand (ON)\r\n'
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
                 '    if (ConditionA1 && ConditionA2)\r\n'
                 '    {\r\n'
                 '        ItemB1.postUpdate (OFF)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    if (ConditionA1 && ConditionA2)\r\n'
                 '    {\r\n'
                 '        ItemB2.sendCommand (ON)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)

    def test_SingleConditionMultiStates(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionMultiStates.rules')
        
        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    if (ConditionA1 && ConditionA2)\r\n'
                 '    {\r\n'
                 '        logInfo ("ItemA2", "Turning On")\r\n'
                 '        ItemB1.postUpdate (OFF)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    if (ConditionA1 && ConditionA2)\r\n'
                 '    {\r\n'
                 '        logInfo ("ItemB2", "Turning On")\r\n'
                 '        ItemB2.sendCommand (ON)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)

class TestSTCA(unittest.TestCase):        
    base_folder = os.path.join('C:', os.sep, 'Users', 'jason', 'OneDrive', 'Documents', 'TMU', 'CPS40A', 'IoT-Mutator')
    test_prog = os.path.join(base_folder, 'STC-A.txl')
    
    def test_Base(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'Base.rules')

        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    ItemB1.postUpdate (OFF)\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    ItemB2.sendCommand (ON)\r\n'
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
                 '    ItemB1.postUpdate (OFF)\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    ItemB2.sendCommand (ON)\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)

    def test_SingleConditionMultiStates(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionMultiStates.rules')
        
        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    logInfo ("ItemA2", "Turning On")\r\n'
                 '    ItemB1.postUpdate (OFF)\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    logInfo ("ItemB2", "Turning On")\r\n'
                 '    ItemB2.sendCommand (ON)\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)

class TestWCC(unittest.TestCase):        
    base_folder = os.path.join('C:', os.sep, 'Users', 'jason', 'OneDrive', 'Documents', 'TMU', 'CPS40A', 'IoT-Mutator')
    test_prog = os.path.join(base_folder, 'WCC.txl')
    
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
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    ItemB2.sendCommand (ON)\r\n'
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
                 '    if (ConditionA1 && ConditionA2)\r\n'
                 '    {\r\n'
                 '        ItemA2.postUpdate (ON)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    if (ItemA2.state == ON)\r\n'
                 '    {\r\n'
                 '        ItemB2.sendCommand (ON)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)

    def test_SingleConditionMultiStates(self):
        test_case = os.path.join(self.base_folder, 'testsuite', 'SingleConditionMultiStates.rules')
        
        test_result = subprocess.run(['txl', test_case, self.test_prog], stdout=subprocess.PIPE)
        actual_result = (
                 'rule "Rule A"\r\n'
                 'when\r\n'
                 '    Item ItemA1 changed to ON\r\n'
                 'then\r\n'
                 '    if (ConditionA1 && ConditionA2)\r\n'
                 '    {\r\n'
                 '        logInfo ("ItemA2", "Turning On")\r\n'
                 '        ItemA2.postUpdate (ON)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n'

                 'rule "Rule B"\r\n'
                 'when\r\n'
                 '    Item ItemB1 changed to OFF\r\n'
                 'then\r\n'
                 '    if (ItemA2.state == ON)\r\n'
                 '    {\r\n'
                 '        logInfo ("ItemB2", "Turning On")\r\n'
                 '        ItemB2.sendCommand (ON)\r\n'
                 '    }\r\n'
                 'end\r\n'
                 '\r\n')

        self.assertEqual(test_result.stdout.decode(), actual_result)



if __name__ == '__main__':
    unittest.main()
