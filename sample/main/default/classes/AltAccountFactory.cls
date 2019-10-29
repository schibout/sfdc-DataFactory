public class AltAccountFactory extends DataFactory.sObjectFactory {

    private Integer count;
    
    public AltAccountFactory() {
        super('Account');
        count = 0;
    }

    /**
     * Generates an Account with a name.
     * 
     * @return  A single sObject.
     */
    public override sObject make() {
        return new Account(
            name = 'Tester' + String.valueOf(count++).leftPad(4, '0')
        );
    }

}