const JOB_CREATE_PATIENT = 0;

synchronise(job) {
  final int id = job['job_id'];
  if (id == JOB_CREATE_PATIENT) {
    // TODO create a patient online
    print(job);
    // TODO remove job from queue
  }
}
