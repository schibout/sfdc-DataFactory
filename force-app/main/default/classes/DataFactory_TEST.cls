@isTest
public class DataFactory_TEST {
    
    @isTest
    private static void type_identification() {
        Account anAccount = new Account();
        sObjectType aType = DataFactory.type('Account');
        System.assertEquals(anAccount.getSObjectType(), aType);
    }

    @isTest
    private static void get_factory() {
        Account anAccount = new Account();
        DataFactory.SObjectFactory factory = DataFactory.get('Account');
        System.assertEquals(anAccount.getSObjectType(), factory.type);
    }

    @isTest
    private static void get_one() {
        sObject anObject = DataFactory.one('Account');
        System.assertNotEquals(null, anObject);
        System.assert(anObject instanceof Account);
    }

    @isTest
    private static void get_many() {
        Integer count = 5;
        List<sObject> someObjects = DataFactory.many('Account', count);
        System.assertEquals(count, someObjects.size());
    }

    @isTest
    private static void cast_type() {
        Account anObject = (Account)DataFactory.one('Account');
    }

    @isTest
    private static void get_one_properties() {
        Map<String, Object> properties = new Map<String, Object>();
        properties.put('Description', 'Just a Test Account');
        Account anAccount = (Account)DataFactory.one('Account', properties);
        System.assertEquals('Just a Test Account', anAccount.Description);
    }

    @isTest
    private static void get_many_properties() {
        Integer count = 5;
        Map<String, Object> properties = new Map<String, Object>();
        properties.put('Description', 'Just a Test Account');
        List<Account> someAccounts = (List<Account>)DataFactory.many('Account', count, properties);
        for (Account anAccount : someAccounts) {
            System.assertEquals('Just a Test Account', anAccount.Description);
        }
    }

    @isTest
    private static void load_json() {
        String jsonData = '';
        jsonData += '[';
        jsonData += '  {';
        jsonData += '    "Name": "Test 1"';
        jsonData += '  },';
        jsonData += '  {';
        jsonData += '    "Name": "Test 2"';
        jsonData += '  }';
        jsonData += ']';
        List<sObject> data = DataFactory.load('Account', jsonData);
        Account anAccount = (Account)data[1];
        System.assertEquals('Test 2', anAccount.Name);
    }

    @isTest
    private static void load_json_attributes() {
        String jsonData = '';
        jsonData += '[';
        jsonData += '  {';
        jsonData += '    "attributes": {';
        jsonData += '      "type": "Account"';
        jsonData += '    },';
        jsonData += '    "Name": "Test 1"';
        jsonData += '  },';
        jsonData += '  {';
        jsonData += '    "attributes": {';
        jsonData += '      "type": "Account"';
        jsonData += '    },';
        jsonData += '    "Name": "Test 2"';
        jsonData += '  }';
        jsonData += ']';
        List<sObject> data = DataFactory.load(jsonData);
        Account anAccount = (Account)data[1];
        System.assertEquals('Test 2', anAccount.Name);
    }

    @isTest
    private static void import_json() {
        String jsonData = '';
        jsonData += '[';
        jsonData += '  {';
        jsonData += '    "Name": "Test 1"';
        jsonData += '  },';
        jsonData += '  {';
        jsonData += '    "Name": "Test 2"';
        jsonData += '  }';
        jsonData += ']';
        List<sObject> data = DataFactory.import('Account', jsonData);
        Account anAccount = (Account)data[1];
        System.assertEquals('Test 2', anAccount.Name);
    }

    @isTest
    private static void import_json_attributes() {
        String jsonData = '';
        jsonData += '[';
        jsonData += '  {';
        jsonData += '    "attributes": {';
        jsonData += '      "type": "Account"';
        jsonData += '    },';
        jsonData += '    "Name": "Test 1"';
        jsonData += '  },';
        jsonData += '  {';
        jsonData += '    "attributes": {';
        jsonData += '      "type": "Account"';
        jsonData += '    },';
        jsonData += '    "Name": "Test 2"';
        jsonData += '  }';
        jsonData += ']';
        List<sObject> data = DataFactory.import(jsonData);
        Account anAccount = (Account)data[1];
        System.assertEquals('Test 2', anAccount.Name);
    }

    @isTest
    private static void setting_get() {
        // Not concerned about the outcome of this setting, only that the method returns.
        DataFactory_Setting__mdt anObject = DataFactory.setting('Test Setting');
    }

    @isTest
    private static void put_value() {
        List<Account> newAccounts = (List<Account>)DataFactory.many('Account', 5);
        Map<String, Object> testData = new Map<String, Object>();
        DataFactory.put(newAccounts, 'Description', 'Put Data Test');
        for (Account anAccount : newAccounts) {
            System.assertEquals('Put Data Test', anAccount.Description);
        }
    }

    @isTest
    private static void put_values() {
        List<Account> newAccounts = (List<Account>)DataFactory.many('Account', 5);
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('Description', 'Put Data Test');
        DataFactory.put(newAccounts, testData);
        for (Account anAccount : newAccounts) {
            System.assertEquals('Put Data Test', anAccount.Description);
        }
    }

}
