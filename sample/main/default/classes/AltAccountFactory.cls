public class AltAccountFactory implements DataFactory.sObjectFactory {
    
    /**
     * Generates an Account with a name.
     * 
     * @return  A single sObject.
     */
    public static sObject one() {
        return new Account(
            name = 'Tester'
        );
    }

    /**
     * Generates a list of Accounts with names.
     * 
     * @param count A number of sObjects to generate.
     * @return  A List of sObjects.
     */
    public static List<sObject> many(Integer count) {
        List<sObject> newObjects = new List<sObject>();
        while (count > 0) {
            Account newObject = (Account)one();
            newObject.Name = 'Test ' + String.valueOf(count);
            newObjects.add(newObject);
            count--;
        }
        return newObjects;
    }

}