@isTest
public class AccountFactory_TEST {
    
    @isTest
    private static void generate_one() {
        Account anAccount = DataFactory.Account.one();
        System.assertNotEquals(null, anAccount);
    }

    @isTest
    private static void generate_many() {
        Integer count = 5;
        List<Account> someAccounts = DataFactory.Account.many(count);
        System.assertEquals(count, someAccounts.size());
    }

}
