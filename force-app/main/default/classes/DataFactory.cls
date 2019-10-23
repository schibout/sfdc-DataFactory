global without sharing class DataFactory {

    private static Map<String, DataFactory.SObjectFactory> factories;
    static {
        // Load factories from DataFactory_Objects Metadata records.
        factories = new Map<String, DataFactory.SObjectFactory>();
        List<DataFactory_Object__mdt> factoryHandlers = [
            SELECT 
                MasterLabel, 
                Apex_Class__c 
            FROM DataFactory_Object__mdt
        ];
        for (DataFactory_Object__mdt factorySettings : factoryHandlers) {
            Type classType = Type.forName(factorySettings.Apex_Class__c);
            if (classType != null) {
                Object classInstance = classType.newInstance();
                if (classInstance instanceof DataFactory.SObjectFactory) {
                    factories.put(
                        factorySettings.MasterLabel, 
                        (DataFactory.SObjectFactory)classInstance
                    );
                }
            }
        }
    }

    public class SObjectNotRegisteredException extends Exception {}

    /**
     * Get a Data Factory for a SObject, if registered in DataFactory_Object__mdt.
     * 
     * @param typeName  Name of the sObject type to find a factory.
     * @return  An class which implements DataFactory.SObjectFactory.
     * @throws  DataFactory.SObjectNotRegisteredException if DataFactory_Object not found.
     */
    public static DataFactory.SObjectFactory get(String typeName) {
        DataFactory.SObjectFactory factory = factories.get(typeName);
        if (factory == null) {
            throw new DataFactory.SObjectNotRegisteredException(typeName);
        } 
        return factory;
    }

    /**
     * Generates an sObject of a given type. 
     * 
     * The sObject itself does not include the Fields properties of the
     * desired type. Fields can either be set using `put(fieldName, value)`
     * or by casting the object to the desired type.
     * 
     * @param typeName  Name of the sObject type to create.
     * @return  A single sObject.
     */
    public static sObject one(String typeName) {
        return Schema.getGlobalDescribe().get(typeName).newSObject();
    }

    /**
     * Generates a list of SObjects with a given size and of a given type. 
     * 
     * The sObject itself does not include the Fields properties of the
     * desired type. Fields can either be set using `put(fieldName, value)`
     * or by casting the object to the desired type.
     * 
     * @param typeName  Name of the Object type to create.
     * @param count A number of sObjects to generate.
     * @return  A List of sObjects.
     */
    public static List<sObject> many(String typeName, Integer count) {
        List<sObject> newObjects = new List<sObject>();
        while (count > 0) {
            newObjects.add(one(typeName));
            count--;
        }
        return newObjects;
    }

    global interface SObjectFactory {
        /**
         * Generates an sObject of a given type. 
         * 
         * The sObject itself does not include the Fields properties of the
         * desired type. Fields can either be set using `put(fieldName, value)`
         * or by casting the object to the desired type.
         * 
         * @return  A single sObject.
         */
        sObject one();
        /**
         * Generates a list of SObjects with a given size and of a given type. 
         * 
         * The sObject itself does not include the Fields properties of the
         * desired type. Fields can either be set using `put(fieldName, value)`
         * or by casting the object to the desired type.
         * 
         * @param count A number of SObjects to generate.
         * @return  A List of sObjects.
         */
        List<sObject> many(Integer count);
    }

}
