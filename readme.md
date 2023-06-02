# Issue

Batch team would like to know if its possible to use one model for our Get/Create/Update operations.  A common scenario is that a user does a Get followed by an update such as:

```
  // get the job
  batchjob = BatchServiceClient.job.get(jobID)
  
  // change a value of the job
  batchjob.priority = 5

  // update the job
  BatchServiceClient.job.update(batchjob
```

Both our Create and Update operations take in as their body a Definition of job that is a subset of the Job object that is passed back from the Get operation. Some of the properties are only valid in 1 or 2 of the definitions.  Some properties are optional in one operation but required in another. Here are some examples, see .\BAtch Combined Models.xlsx for full breakdown

- Property 'id' is returned by the Get call, Required by the Create Call, and not allowed as part of the Update definition
- Property 'displayName' is returned by the Get call, Optional by the Create Call, and not allowed as part of the Update definition
- Property 'poolInfo' is returned by the Get call and Required by both the Create and Update Operations
- Property 'url' is only returned by the Get call

We need a way to define both visibility of a property per operation and requirement.  TypeSpec gives us the @visibility attribute to describe visibility and the '?' modifier to specify if a parameter is optional.

Two issues:
1) The '?' modifier is globally tied to the property in that you can not specify that in one operation a property is optional but in another its required.

2) We tried to use @visibility to represent when a property was valid for an operations such as

```
  // Part of get only
  @visibility("read")
  url?: string;

  // Part of both get and create only
  @visibility("read", "create")
  id: string;

  // Part of both get, create, and update 
  @visibility("read", "create", "update")
  priority?: int32;
```

but when the python code was emitted (refer to _models.py) the concept of "create" vs "update" is lost. For the 3 above properties here is how that are define in the python BatchJob class 

```
    url: Optional[str] = rest_field(readonly=True)
    id: str = rest_field()
    priority: Optional[int] = rest_field()
```

When our job operations are called the json serializer that python uses will determine if to include a property only if it is marked as read only.  In this example if you called the create operation then the 'url' will not get serialized into the body as its readonly which is expected.  But both 'id' and 'priority' are not marked as readonly and will get serialized into both the Create and Update body's.  Since 'id' has no additional attributes to let the json serializer know that this field is not valid for update it will be included in the call and the call will fail.

