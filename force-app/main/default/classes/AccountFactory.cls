public class AccountFactory {
    
    /**
     * Generates an Account with a name.
     * 
     * @return  A single sObject.
     */
    public Account one() {
        return new Account(
            name = 'Test'
        );
    }

    /**
     * Generates a list of Accounts with names.
     * 
     * @param count A number of sObjects to generate.
     * @return  A List of sObjects.
     */
    public List<Account> many(Integer count) {
        List<Account> newObjects = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account newObject = one();
            newObject.Name += ' ' + String.valueOf(i);
            newObjects.add(newObject);
        }
        return newObjects;
    }

}