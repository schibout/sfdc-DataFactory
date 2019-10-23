global without sharing class DataFactory {

    public static Map<String, DataFactory.SObjectFactory> factories;
    static {
        // Load factories from DataFactory_Objects Metadata records.
        factories = new Map<String, DataFactory.SObjectFactory>();
        for (DataFactory_Object__mdt factoryMap : [SELECT MasterLabel, Apex_Class__c FROM DataFactory_Object__mdt]) {
            Type classType = Type.forName(factoryMap.Apex_Class__c);
            Object classInstance;
            if (classType != null) {
                classInstance = classType.newInstance();
                if (classInstance instanceof DataFactory.SObjectFactory) {
                    DataFactory.SObjectFactory factory = (DataFactory.SObjectFactory)classInstance;
                    factories.put(factoryMap.MasterLabel, factory);
                }
            }
        }
    }

    public static DataFactory.SObjectFactory get(String typeName) {
        return factories.get(typeName);
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
