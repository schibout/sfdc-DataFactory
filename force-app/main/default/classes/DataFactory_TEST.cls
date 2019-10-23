@isTest
public class DataFactory_TEST {
    
    @isTest
    private static void generate_one() {
        sObject anObject = DataFactory.one('Account');
        System.assertNotEquals(null, anObject);
    }

    @isTest
    private static void generate_many() {
        Integer count = 5;
        List<sObject> someObjects = DataFactory.many('Account', count);
        System.assertEquals(count, someObjects.size());
    }

    @isTest
    private static void cast_one() {
        Account anObject = (Account)DataFactory.one('Account');
    }

    @isTest
    private static void cast_many() {
        Integer count = 5;
        List<Account> someObjects = (List<Account>)DataFactory.many('Account', count);
    }

}