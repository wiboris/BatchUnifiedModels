import "@typespec/rest";
import "@typespec/versioning";
import "@typespec/http";
import "@azure-tools/typespec-azure-core";

using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.Versioning;
using Azure.Core;
using Azure.Core.Traits;

@service({
  title: "BatchClient",
})

@doc("A client for issuing REST requests to the Azure Batch service.")
@versioned(BatchService.Versions)
namespace BatchService;

@doc("The Batch service version.")
enum Versions {
   @doc("Version 2022-08-31")
   @useDependency(Azure.Core.Versions.v1_0_Preview_2)
  `2022-08-30`,
}


#suppress "@azure-tools/typespec-azure-core/casing-style" "The names of Model types must use camelCase"
interface Job {
 
  @doc("Gets information about the specified Job.")
  @route("/jobs/{jobId}")
  @get
  Get is RpcOperation<{
        @doc("The ID of the Job.")
        @path
        jobId: string;

        @doc("An OData $select clause.")
        @query
        $select?: string;

        @doc("An OData $expand clause.")
        @query
        $expand?: string;
      },
    BatchJob
  >;

  
  @doc("Updates a specified Job")
  @route("/jobs/{jobId}")
  @put
  Update is RpcOperation<{

        @doc("The ID of the Job whose properties you want to update.")
        @path
        jobId: string;

        @doc("The parameters for the request.")
        @body
        parameters : BatchJob;
      },{}
  >;

  @doc("Creates a specified Job")
  @route("/jobs")
  @post
  Create is RpcOperation<{
      
      @doc("The Job to be crated.")
      @body
      parameters: BatchJob;
    },{}
  >;

}

/////////////////////  Models //////////////////////////


@doc("An Azure Batch Job.")
model BatchJob {
  @doc("""
The ID is case-preserving and case-insensitive (that is, you may not have two
IDs within an Account that differ only by case).
""")
  @visibility("read", "create")
  id: string;

  @doc("The display name for the Job.")
  @visibility("read", "create")
  displayName?: string;

  @doc("""
Whether Tasks in the Job can define dependencies on each other. The default is
false.
""")
  @visibility("read", "create")
  usesTaskDependencies?: boolean;

  @doc("The URL of the Job.")
  @visibility("read")
  url?: string;

  @doc("""
This is an opaque string. You can use it to detect whether the Job has changed
between requests. In particular, you can be pass the ETag when updating a Job
to specify that your changes should take effect only if nobody else has
modified the Job in the meantime.
""")
  @visibility("read")
  eTag?: string;

  @doc("""
This is the last time at which the Job level data, such as the Job state or
priority, changed. It does not factor in task-level changes such as adding new
Tasks or Tasks changing state.
""")
  @visibility("read")
  lastModified?: utcDateTime;

  @doc("The creation time of the Job.")
  @visibility("read")
  creationTime?: utcDateTime;

  @doc("The state of the Job.")
  @visibility("read")
  state?: string;

  @doc("The time at which the Job entered its current state.")
  @visibility("read")
  stateTransitionTime?: utcDateTime;

  @doc("This property is not set if the Job is in its initial Active state.")
  @visibility("read")
  previousState?: string;

  @doc("This property is not set if the Job is in its initial Active state.")
  @visibility("read")
  previousStateTransitionTime?: utcDateTime;

  @doc("""
Priority values can range from -1000 to 1000, with -1000 being the lowest
priority and 1000 being the highest priority. The default value is 0.
""")
  @visibility("read", "create", "update")
  priority?: int32;

  @doc("""
If the value is set to True, other high priority jobs submitted to the system
will take precedence and will be able requeue tasks from this job. You can
update a job's allowTaskPreemption after it has been created using the update
job API.
""")
  @visibility("read", "create", "update")
  allowTaskPreemption?: boolean;

  @doc("""
The value of maxParallelTasks must be -1 or greater than 0 if specified. If not
specified, the default value is -1, which means there's no limit to the number
of tasks that can be run at once. You can update a job's maxParallelTasks after
it has been created using the update job API.
""")
  @visibility("read", "create", "update")
  maxParallelTasks?: int32 = -1;

  @doc("The execution constraints for a Job.")
  constraints?: string;

  @doc("""
The Job Manager Task is automatically started when the Job is created. The
Batch service tries to schedule the Job Manager Task before any other Tasks in
the Job. When shrinking a Pool, the Batch service tries to preserve Nodes where
Job Manager Tasks are running for as long as possible (that is, Compute Nodes
running 'normal' Tasks are removed before Compute Nodes running Job Manager
Tasks). When a Job Manager Task fails and needs to be restarted, the system
tries to schedule it at the highest priority. If there are no idle Compute
Nodes available, the system may terminate one of the running Tasks in the Pool
and return it to the queue in order to make room for the Job Manager Task to
restart. Note that a Job Manager Task in one Job does not have priority over
Tasks in other Jobs. Across Jobs, only Job level priorities are observed. For
example, if a Job Manager in a priority 0 Job needs to be restarted, it will
not displace Tasks of a priority 1 Job. Batch will retry Tasks when a recovery
operation is triggered on a Node. Examples of recovery operations include (but
are not limited to) when an unhealthy Node is rebooted or a Compute Node
disappeared due to host failure. Retries due to recovery operations are
independent of and are not counted against the maxTaskRetryCount. Even if the
maxTaskRetryCount is 0, an internal retry due to a recovery operation may
occur. Because of this, all Tasks should be idempotent. This means Tasks need
to tolerate being interrupted and restarted without causing any corruption or
duplicate data. The best practice for long running Tasks is to use some form of
checkpointing.
""")
  @visibility("read", "create")
  jobManagerTask?: string;

  @doc("""
The Job Preparation Task is a special Task run on each Compute Node before any
other Task of the Job.
""")
  @visibility("read", "create")
  jobPreparationTask?: string;

  @doc("""
The Job Release Task is a special Task run at the end of the Job on each
Compute Node that has run any other Task of the Job.
""")
  @visibility("read", "create")
  jobReleaseTask?: string;

  @doc("""
Individual Tasks can override an environment setting specified here by
specifying the same setting name with a different value.
""")
  @visibility("read", "create")
  commonEnvironmentSettings?: string[];

  @doc("Specifies how a Job should be assigned to a Pool.")
  poolInfo?: string;

  @doc("The default is noaction.")
  onAllTasksComplete?: string;

  @doc("""
A Task is considered to have failed if has a failureInfo. A failureInfo is set
if the Task completes with a non-zero exit code after exhausting its retry
count, or if there was an error starting the Task, for example due to a
resource file download error. The default is noaction.
""")
  @visibility("read", "create")
  onTaskFailure?: string;

  @doc("The network configuration for the Job.")
  @visibility("read", "create")
  networkConfiguration?: string;

  @doc("""
The Batch service does not assign any meaning to metadata; it is solely for the
use of user code.
""")
  metadata?: string[];

  @doc("Contains information about the execution of a Job in the Azure Batch service.")
  @visibility("read")
  executionInfo?: string;

  @doc("""
This property is populated only if the CloudJob was retrieved with an expand
clause including the 'stats' attribute; otherwise it is null. The statistics
may not be immediately available. The Batch service performs periodic roll-up
of statistics. The typical delay is about 30 minutes.
""")
  @visibility("read")
  stats?: string;
}





