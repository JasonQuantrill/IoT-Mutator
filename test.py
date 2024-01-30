import os
import unittest
import subprocess

class TestStringMethods(unittest.TestCase):
    folder = 'C:\\Users\\jason\\OneDrive\\Documents\\TMU\\CPS40A\\IoT-Mutator'

    def test_SAC(self):
        test_prog = f'{self.folder}\\SAC.txl'

        # Test with no conditions
        test_case = f'{self.folder}\\IoTB\\lock.rules'
        test_result = subprocess.run(f'txl {test_case} {test_prog}', stdout=subprocess.PIPE)
        actual_result = ('rule "unlock door in foyer"\r\nwhen\r\n    Item Foyer_Light changed to ON\r\nthen\r\n    '
                         '{\r\n        Front_Door_Lock.postUpdate (ON)}\r\n\r\nend\r\n\r\nrule "turn off hallway light"'
                         '\r\nwhen\r\n    Item Foyer_Light changed to ON\r\nthen\r\n    {\r\n        Front_Door_Lock.sendCommand (OFF)}'
                         '\r\n\r\nend\r\n\r\n')
        self.assertEqual(test_result.stdout.decode(), actual_result)

        # Test with single line condition
        test_case = f'{self.folder}\\IoTB\\lock.rules'
        test_result = subprocess.run(f'txl {test_case} {test_prog}', stdout=subprocess.PIPE)
        actual_result = ('rule "unlock door in foyer"\r\nwhen\r\n    Item Foyer_Light changed to ON\r\nthen\r\n    '
                         '{\r\n        Front_Door_Lock.postUpdate (ON)}\r\n\r\nend\r\n\r\nrule "turn off hallway light"'
                         '\r\nwhen\r\n    Item Foyer_Light changed to ON\r\nthen\r\n    {\r\n        Front_Door_Lock.sendCommand (OFF)}'
                         '\r\n\r\nend\r\n\r\n')
        self.assertEqual(test_result.stdout.decode(), actual_result)



if __name__ == '__main__':
    unittest.main()
