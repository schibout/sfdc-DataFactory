@isTest
public class AccountFactory_TEST {
    
    @isTest
    private static void generate_one() {
        Account anAccount = (Account)DataFactory.one('Account');
        System.assertNotEquals(null, anAccount);
    }

    @isTest
    private static void generate_many() {
        Integer count = 5;
        List<Account> someAccounts = (List<Account>)DataFactory.many('Account', count);
        System.assertEquals(count, someAccounts.size());
    }

}
