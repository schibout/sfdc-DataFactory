public class AccountFactory extends DataFactory.sObjectFactory {

    public AccountFactory() {
        super('Account');
    }
    
    /**
     * Generates an Account with a name.
     * 
     * @return  A single sObject.
     */
    public override sObject make() {
        return new Account(
            name = 'Test'
        );
    }

}