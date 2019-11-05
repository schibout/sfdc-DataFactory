global without sharing class DataFactory {

    
    private static Map<String, SObjectFactory> factories = new Map<String, SObjectFactory>();
    private static Map<String, String> factoryHandlers;
    private static Map<String, DataFactory_Setting__mdt> settings;
    static {
        // Load factories from SObjectFactory Metadata records.
        factoryHandlers = new Map<String, String>();
        List<SObjectFactory__mdt> registeredFactories = [
            SELECT 
                MasterLabel, 
                Apex_Class__c 
            FROM SObjectFactory__mdt
        ];
        for (SObjectFactory__mdt factorySettings : registeredFactories) {
            factoryHandlers.put(
                factorySettings.MasterLabel, 
                factorySettings.Apex_Class__c
            );
        }

        // Load settings from DataFactory_Settings Metadata records.
        settings = new Map<String, DataFactory_Setting__mdt>();
        List<DataFactory_Setting__mdt> registeredSettings = [
            SELECT 
                MasterLabel, 
                Value__c 
            FROM DataFactory_Setting__mdt
        ];
        for (DataFactory_Setting__mdt setting : registeredSettings) {
            settings.put(setting.MasterLabel, setting);
        }
    }

    private static final Type FACTORY_TYPE = Type.forName('DataFactory.SObjectFactory');

    
    /**
     * Finds the SObject Type from a name.
     * 
     * @param typeName  Name of the sObject type.
     * @return  A sObjectType.
     */
    @TestVisible
    private static sObjectType type(String typeName) {
        return Schema.getGlobalDescribe().get(typeName);
    }

    /**
     * Load a SObjectFactory class instance from a class name.ApexPages
     * 
     * @param className Name of the SOBjectFactory class to load.
     * @return  An SObjectFactory instance, or null if not valid. 
     */
    private static SObjectFactory getFactory(String className) {
        Type classType = Type.forName(className);
        if (classType != null) {
            if (FACTORY_TYPE.isAssignableFrom(classType)) {
                return (SObjectFactory)classType.newInstance();     
            }
        }
        return null;
    }

    /**
     * Get a factory for an SObject, if registered in SObjectFactory__mdt.
     * 
     * @param typeName  Name of the sObject type to find a factory.
     * @return  An class which extends DataFactory.SObjectFactory.
     */
    public static SObjectFactory get(String typeName) {
        if (factories.containsKey(typeName)) { // Check loaded factories.
            return factories.get(typeName);
        }
        SObjectFactory factory;
        String handler = factoryHandlers.get(typeName);
        if (!String.isBlank(handler)) {
            factory = getFactory(handler);
        }
        if (factory == null) { // Create a generic factory.
            factory = new SObjectFactory(typeName);
        }
        factories.put(typeName, factory); // Cache the factory for future reference.
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
        SObjectFactory factory = get(typeName);
        return factory.make();
    }
    /**
     * Generates an sObject of a given type. 
     * 
     * @param typeName  Name of the sObject type to create.
     * @return  A single sObject.
     */
    public static sObject one(String typeName, Map<String, Object> properties) {
        SObject item = one(typeName);
        put(item, properties);
        return item;
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
     * @param properties     A Map of field names to values.
     * @return  A List of sObjects.
     */
    public static List<SObject> many(String typeName, Integer count) {
        SObjectFactory factory = get(typeName);
        return factory.make(count);
    }
    /**
     * Generates a list of SObjects with a given size and of a given type. 
     *
     * @param typeName  Name of the Object type to create.
     * @param count A number of sObjects to generate.
     * @param properties     A Map of field names to values.
     * @return  A List of sObjects.
     */
    public static List<SObject> many(String typeName, Integer count, Map<String, Object> properties) {
        List<SObject> items = many(typeName, count);
        put(items, properties);
        return items;
    }

    /**
     * Puts a value into an SObject by field name.
     * 
     * @param target  An SObject to apply properties.
     * @param field    Name of the field to put value.
     * @param properties   Value to apply to put in the field.
     */
    public static void put(SObject target, String field, Object value) {
        target.put(field, value);
    }

    /**
     * Puts a value into many SObjects by field name.
     * 
     * @param target  An SObject to apply properties.
     * @param field    Name of the field to put value.
     * @param properties   Value to apply to put in the field.
     */
    public static void put(List<SObject> targets, String field, Object value) {
        for (SObject target : targets) {
            put(target, field, value);
        }
    }

    /**
     * Puts values into an SObject from a map of field names.
     * 
     * @param target  An SObject to apply properties.
     * @param properties    A Map of field names to values.
     */
    public static void put(SObject target, Map<String, Object> properties) {
        for (String key : properties.keySet()) {
            put(target, key, properties.get(key));
        }
    }

    /**
     * Puts values into many SObjects from a map of field names.
     * 
     * @param target  An SObject to apply properties.
     * @param properties    A Map of field names to values.
     */
    public static void put(List<SObject> targets, Map<String, Object> properties) {
        for (SObject target : targets) {
            put(target, properties);
        }
    }

    /**
     * Generates sObjects from a JSON document with a given type.
     * 
     * JSON document should be an array of Objects with properties appropriate
     * for the intended type. E.g.
     * 
     * ```json
     * [
     *     {
     *         "Name": "Test" 
     *     }   
     * ]
     * ```
     * 
     * @param typeName  Name of the Object type to create.
     * @param jsonString A JSON-formatted String to parse.
     * @return  A List of Objects generated from the resource.
     */
    public static List<sObject> load(String typeName, String jsonString) {
        List<sObject> data = new List<sObject>();
        SObjectFactory factory = get(typeName);
        for (Object row : (List<Object>)JSON.deserializeUntyped(jsonString)) {
            SObject item = factory.make();
            put(item, (Map<String, Object>)row);
            data.add(item);
        }
        return data;
    }
    /**
     * Generates sObjects from a JSON document with a given type.
     * 
     * @param typeName  Name of the Object type to create.
     * @param resource A Static Resource containing a JSON-serialized objects.
     * @return  A List of Objects generated from the resource.
     */
    public static List<sObject> load(String typeName, StaticResource resource) {
        return load(typeName, resource.Body.toString());
    }
    /**
     * Generates objects from a JSON document with a type indicated in the document.
     * 
     * JSON document should be an array of Objects with and "attributes" property
     * first, and additional properties for Fields for the intended type. E.g.
     * 
     * ```json
     * [
     *     {
     *         "attributes": {
     *             "type": "Account"
     *         },
     *         "Name": "Test" 
     *     }   
     * ]
     * ```
     * 
     * @param jsonString A JSON-formatted String to parse.
     * @return  A List of sObjects generated from the resource.
     */
    public static List<sObject> load(String jsonString) {
        List<SObject> loadedObjects = new List<SObject>();
        for (SObject importedObject : import(jsonString)) {
            String typeName = importedObject.getSObjectType().getDescribe().getName();
            SObjectFactory factory = get(typeName);
            SObject item = factory.make();
            put(item, importedObject.getPopulatedFieldsAsMap());
            loadedObjects.add(item);
        }
        return loadedObjects;
    }
    /**
     * Generates objects from a JSON document with a type, from a Static Resource.
     * 
     * @param resource A Static Resource containing a JSON-serialized objects.
     * @return  A List of sObjects generated from the resource.
     */
    public static List<sObject> load(StaticResource resource) {
        return load(resource.Body.toString());
    }


    /**
     * Generates sObjects from a JSON document with a given type.
     * 
     * JSON document should be an array of Objects with properties appropriate
     * for the intended type. E.g.
     * 
     * ```json
     * [
     *     {
     *         "Name": "Test" 
     *     }   
     * ]
     * ```
     * 
     * @param typeName  Name of the Object type to create.
     * @param jsonString A JSON-formatted String to parse.
     * @return  A List of Objects generated from the resource.
     */
    public static List<sObject> import(String typeName, String jsonString) {
        List<sObject> data = new List<sObject>();
        sObjectType objType = type(typeName);
        for (Object row : (List<Object>)JSON.deserializeUntyped(jsonString)) {
            SObject item = objType.newSObject();
            put(item, (Map<String, Object>)row);
            data.add(item);
        }
        return data;
    }
    /**
     * Generates sObjects from a JSON document with a given type, from a Static Resource
     * 
     * @param typeName  Name of the Object type to create.
     * @param resource A Static Resource containing a JSON-serialized objects.
     * @return  A List of Objects generated from the resource.
     */
    public static List<sObject> import(String typeName, StaticResource resource) {
        return import(typeName, resource.Body.toString());
    }

    /**
     * Generates objects from a JSON document with a type indicated in the document.
     * 
     * JSON document should be an array of Objects with and "attributes" property
     * first, and additional properties for Fields for the intended type. E.g.
     * 
     * ```json
     * [
     *     {
     *         "attributes": {
     *             "type": "Account"
     *         },
     *         "Name": "Test" 
     *     }   
     * ]
     * ```
     * 
     * @param jsonString A JSON-formatted String to parse.
     * @return  A List of sObjects generated from the resource.
     */
    public static List<sObject> import(String jsonString) {
        return (List<sObject>)JSON.deserialize(jsonString, List<sObject>.class);
    }
    /**
     * Generates objects from a JSON document with a type, from a Static Resource.
     * 
     * @param resource A Static Resource containing a JSON-serialized objects.
     * @return  A List of sObjects generated from the resource.
     */
    public static List<sObject> import(StaticResource resource) {
        return import(resource.Body.toString());
    }

    /**
     * Finds a DataFactory Setting by label.
     * 
     * @param  label    A String indicating the DataFactory Setting to find.
     * @ return   A DataFactory_Setting__mdt containing a Value__c.
     */
    public static DataFactory_Setting__mdt setting(String label) {
        return settings.get(label);
    }

    /**
     * SObjectFactory can be implemented to create a custom generator for a
     * particular type of SObject.
     * 
     * The interface itself requires a single `make()` method, returning a 
     * single SObject of the type. However, the interface extends Iterator,
     * and therefore must also implement `hasNext()` and `next()`.
     */
    public virtual class SObjectFactory {
        public SObjectType type {get; private set;}

        public SObjectFactory(sObjectType objType) {
            type = objType;
        }
        public SObjectFactory(String typeName) {
            this(DataFactory.type(typeName));
        }

        /**
         * Generates an sObject of a given type. 
         * 
         * The sObject itself does not include the Fields properties of the
         * desired type. Fields can either be set using `put(fieldName, value)`
         * or by casting the object to the desired type.
         * 
         * @return  A single sObject.
         */
        public virtual SObject make() {
            return type.newSObject();
        }
        /**
         * Generates a list of sObject of a given type. 
         * 
         * The sObject itself does not include the Fields properties of the
         * desired type. Fields can either be set using `put(fieldName, value)`
         * or by casting the object to the desired type.
         * 
         * @param count Number of records to create.
         * @return  A list of sObjects.
         */
        public virtual List<SObject> make(Integer count) {
            List<SObject> newObjects = new List<SObject>();
            while (count > 0) {
                SObject newObject = make();
                newObjects.add(newObject);
                count--;
            }
            return newObjects;
        }
    }

}
