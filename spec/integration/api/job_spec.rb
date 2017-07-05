require "spec_helper"

module Nomad
  describe Job do
    subject { nomad_test_client.job }

    before(:context) {
      jobfile = File.read(File.expand_path("../../../support/jobs/job.json", __FILE__))
      nomad_test_client.post("/v1/jobs", jobfile)
    }

    describe "#list" do
      it "returns all jobs" do
        result = subject.list
        expect(result).to be
        expect(result[0].name).to eq("job")
        expect(result[0].job_summary).to be
      end
    end

    describe "#create" do
      it "creates a job" do
        job = JSON.parse(File.read(File.expand_path("../../../support/jobs/job.json", __FILE__)))
        job["ID"] = "new-job"
        job["Name"] = "new-job"
        result = subject.create(JSON.fast_generate(job))
        expect(result).to be_a(JobCreate)
      end
    end

    describe "#read" do
      it "reads a job" do
        job = subject.read("job")
        expect(job).to be_a(JobVersion)
        expect(job.all_at_once).to be(true)
        expect(job.constraints.size).to eq(0)
        expect(job.create_index).to be_a(Integer)
        expect(job.datacenters).to eq(["dc1"])
        expect(job.id).to eq("job")
        expect(job.job_modify_index).to be_a(Integer)
        expect(job.meta).to eq({"foo" => "bar"})
        expect(job.modify_index).to be_a(Integer)
        expect(job.name).to eq("job")
        expect(job.parameterized_job).to be(nil)
        expect(job.parent_id).to be(nil)
        expect(job.payload).to be(nil)
        expect(job.periodic).to be(nil)
        expect(job.region).to eq("global")
        expect(job.stable).to be(false)
        expect(job.status).to eq("running")
        expect(job.running?).to be(true)
        expect(job.status_description).to be(nil)
        expect(job.stop).to be(false)

        group = job.groups[0]
        expect(group).to be
        expect(group.constraints[0]).to be
        expect(group.constraints[0].l_target).to eq("${attr.os.signals}")
        expect(group.constraints[0].operand).to eq("set_contains")
        expect(group.constraints[0].r_target).to eq("SIGHUP")
        expect(group.count).to eq(3)
        expect(group.ephemeral_disk).to be
        expect(group.ephemeral_disk.migrate).to be(false)
        expect(group.ephemeral_disk.size).to eq(10*Size::MEGABYTE)
        expect(group.ephemeral_disk.sticky).to be(false)
        expect(group.meta).to eq({"zip" => "zap"})
        expect(group.name).to eq("group")
        expect(group.restart_policy).to be
        expect(group.restart_policy.attempts).to eq(10)
        expect(group.restart_policy.delay).to eq(25*Duration::SECOND)
        expect(group.restart_policy.interval).to eq(300*Duration::SECOND)
        expect(group.restart_policy.mode).to eq("delay")

        task = group.tasks[0]
        expect(task).to be
        expect(task.artifacts[0]).to be
        expect(task.artifacts[0].destination).to eq("local/")
        expect(task.artifacts[0].options).to eq({"checksum" => "md5:d2267250309a62b032b2b43312c81fec"})
        expect(task.artifacts[0].source).to eq("https://github.com/hashicorp/http-echo/releases/download/v0.2.3/http-echo_0.2.3_SHA256SUMS")
        expect(task.config).to eq({"args" => ["1000"], "command" => "/bin/sleep"})
        expect(task.constraints).to eq([])
        expect(task.dispatch_payload).to be(nil)
        expect(task.driver).to eq("raw_exec")
        expect(task.env).to eq({"key" => "value"})
        expect(task.kill_timeout).to eq(250*Duration::MILLI_SECOND)
        expect(task.leader).to be(false)
        expect(task.log_config.max_file_size).to eq(2*Size::MEGABYTE)
        expect(task.log_config.max_files).to eq(1)
        expect(task.meta).to eq({"zane" => "willow"})
        expect(task.name).to eq("task")

        resources = task.resources
        expect(resources).to be
        expect(resources.cpu).to eq(20)
        expect(resources.disk).to eq(0)
        expect(resources.iops).to eq(0)
        expect(resources.memory).to eq(12*Size::MEGABYTE)

        network = resources.networks[0]
        expect(network).to be
        expect(network.cidr).to be(nil)
        expect(network.device).to be(nil)
        expect(network.dynamic_ports[0].label).to eq("db")
        expect(network.dynamic_ports[0].value).to eq(0)
        expect(network.dynamic_ports[1].label).to eq("http")
        expect(network.dynamic_ports[1].value).to eq(0)
        expect(network.ip).to be(nil)
        expect(network.megabits).to eq(1*Size::MEGABIT)
        expect(network.reserved_ports).to eq([])

        service1 = task.services[0]
        expect(service1).to be
        expect(service1.name).to eq("service-1")
        expect(service1.port_label).to eq("db")
        expect(service1.tags).to eq(["tag1"])
        expect(service1.checks[0].args).to eq([])
        expect(service1.checks[0].command).to be(nil)
        expect(service1.checks[0].initial_status).to be(nil)
        expect(service1.checks[0].interval).to eq(10*Duration::SECOND)
        expect(service1.checks[0].name).to eq("alive")
        expect(service1.checks[0].path).to be(nil)
        expect(service1.checks[0].port_label).to be(nil)
        expect(service1.checks[0].protocol).to be(nil)
        expect(service1.checks[0].timeout).to eq(2*Duration::SECOND)
        expect(service1.checks[0].tls_skip_verify).to be(false)
        expect(service1.checks[0].type).to eq("tcp")
        expect(service1.checks[1].args).to eq([])
        expect(service1.checks[1].command).to be(nil)
        expect(service1.checks[1].initial_status).to be(nil)
        expect(service1.checks[1].interval).to eq(10*Duration::SECOND)
        expect(service1.checks[1].name).to eq("still-alive")
        expect(service1.checks[1].path).to eq("/")
        expect(service1.checks[1].port_label).to be(nil)
        expect(service1.checks[1].protocol).to be(nil)
        expect(service1.checks[1].timeout).to eq(2*Duration::SECOND)
        expect(service1.checks[1].tls_skip_verify).to be(false)
        expect(service1.checks[1].type).to eq("http")

        service2 = task.services[1]
        expect(service2).to be
        expect(service2.checks).to eq([])
        expect(service2.name).to eq("service-2")
        expect(service2.port_label).to eq("db")
        expect(service2.tags).to eq([])

        expect(task.templates[0].change_mode).to eq("signal")
        expect(task.templates[0].change_signal).to eq("SIGHUP")
        expect(task.templates[0].destination).to eq("local/file-1.yml")
        expect(task.templates[0].data).to eq("key: {{ key \"service/my-key\" }}")
        expect(task.templates[0].env).to be(false)
        expect(task.templates[0].left_delim).to eq("{{")
        expect(task.templates[0].permissions).to eq("0644")
        expect(task.templates[0].right_delim).to eq("}}")
        expect(task.templates[0].source).to be(nil)
        expect(task.templates[0].splay).to eq(5*Duration::SECOND)

        expect(task.templates[1].change_mode).to eq("signal")
        expect(task.templates[1].change_signal).to eq("SIGHUP")
        expect(task.templates[1].destination).to eq("local/file-2.yml")
        expect(task.templates[1].data).to be(nil)
        expect(task.templates[1].env).to be(false)
        expect(task.templates[1].left_delim).to eq("{{")
        expect(task.templates[1].permissions).to eq("0644")
        expect(task.templates[1].right_delim).to eq("}}")
        expect(task.templates[1].source).to eq("local/http-echo_0.2.3_SHA256SUMS")
        expect(task.templates[1].splay).to eq(5*Duration::SECOND)

        expect(task.user).to be(nil)
        expect(task.vault).to be(nil)

        expect(job.type).to eq("service")
        expect(job.vault_token).to be(nil)
        expect(job.version).to be_a(Integer)
      end
    end

    describe "#plan" do
      it "plans a new job" do
        job = JSON.parse(File.read(File.expand_path("../../../support/jobs/job.json", __FILE__)))
        job["Job"]["ID"] = "plan-job"
        job["Job"]["Name"] = "plan-job"
        result = subject.plan(JSON.fast_generate(job))
        expect(result).to be_a(JobPlan)
        expect(result.job_modify_index).to be_a(Integer)
        # This is a creation so there is no diff
        expect(result.diff).to be_a(Diff)

        fields_diff = result.diff.fields
        expect(fields_diff).to be_a(Array)
        expect(fields_diff.length).to be(7)

        # It's a new Job so all "old" will be "" and
        # every type will be "added"
        # Also for fields we don't expect annotations
        7.times do |i|
          expect(fields_diff[i]).to be_a(FieldDiff)
          expect(fields_diff[i].annotations).to eq([])
          expect(fields_diff[i].old).to eq('')
          expect(fields_diff[i].type).to eq('Added')
        end

        expect(fields_diff[0].name).to eq('AllAtOnce')
        expect(fields_diff[0].new).to eq('true')
        expect(fields_diff[1].name).to eq('Meta[foo]')
        expect(fields_diff[1].new).to eq('bar')
        expect(fields_diff[2].name).to eq('Name')
        expect(fields_diff[2].new).to eq('plan-job')
        expect(fields_diff[3].name).to eq('Priority')
        expect(fields_diff[3].new).to eq('50')
        expect(fields_diff[4].name).to eq('Region')
        expect(fields_diff[4].new).to eq('global')
        expect(fields_diff[5].name).to eq('Type')
        expect(fields_diff[5].new).to eq('service')
        expect(fields_diff[6].name).to eq('VaultToken')
        expect(fields_diff[6].new).to eq('root')

        object_diffs = result.diff.objects
        expect(object_diffs).to be_a(Array)
        expect(object_diffs.length).to be(2)
        2.times do |i|
          expect(object_diffs[i]).to be_a(ObjectDiff)
          expect(object_diffs[i].type).to eq('Added')
        end

        datacenter_diff = object_diffs[0]
        expect(datacenter_diff.name).to eq('Datacenters')
        datacenter_fields = datacenter_diff.fields
        expect(datacenter_fields.length).to eq(1)
        expect(datacenter_fields[0]).to be_a(FieldDiff)
        expect(datacenter_fields[0].name).to eq('Datacenters')
        expect(datacenter_fields[0].new).to eq('dc1')
        expect(datacenter_fields[0].old).to eq('')
        expect(datacenter_fields[0].annotations).to eq([])
        expect(datacenter_fields[0].type).to eq('Added')

        update_diff = object_diffs[1]
        expect(update_diff.name).to eq('Update')
        update_fields = update_diff.fields
        expect(update_fields.length).to eq(2)
        expect(update_fields[0].name).to eq('MaxParallel')
        expect(update_fields[0].new).to eq('0')
        expect(update_fields[0].old).to eq('')
        expect(update_fields[0].type).to eq('Added')
        expect(update_fields[0].annotations).to eq([])

        expect(update_fields[1].name).to eq('Stagger')
        expect(update_fields[1].new).to eq('0')
        expect(update_fields[1].old).to eq('')
        expect(update_fields[1].type).to eq('Added')
        expect(update_fields[1].annotations).to eq([])

        task_groups_diff = result.diff.task_groups
        expect(task_groups_diff).to be_a(Array)
        expect(task_groups_diff.length).to be(1)
        expect(task_groups_diff.first).to be_a(TaskGroupDiff)

        tasks_diff = result.diff.task_groups.first.tasks

        expect(tasks_diff.length).to be(1)
        task_diff = tasks_diff[0]
        expect(task_diff).to be_a(TaskDiff)
        expect(task_diff.annotations.length).to eq(1)
        expect(task_diff.annotations).to eq(['forces create'])
        expect(task_diff.name).to eq('task')


        task_diff_fields = task_diff.fields
        expect(task_diff_fields).to be_a(Array)
        expect(task_diff_fields.length).to eq(5)
        5.times do |i|
          expect(task_diff_fields[i].annotations).to eq([])
          expect(task_diff_fields[i].old).to eq('')
          expect(task_diff_fields[i].type).to eq('Added')
        end
        expect(task_diff_fields[0].name).to eq('Driver')
        expect(task_diff_fields[0].new).to eq('raw_exec')
        expect(task_diff_fields[1].name).to eq('Env[key]')
        expect(task_diff_fields[1].new).to eq('value')
        expect(task_diff_fields[2].name).to eq('KillTimeout')
        expect(task_diff_fields[2].new).to eq('250000000')
        expect(task_diff_fields[3].name).to eq('Leader')
        expect(task_diff_fields[3].new).to eq('false')
        expect(task_diff_fields[4].name).to eq('Meta[zane]')
        expect(task_diff_fields[4].new).to eq('willow')

        task_diff_objects = task_diff.objects
        expect(task_diff_objects).to be_a(Array)
        expect(task_diff_objects.length).to eq(8)

        config_object = task_diff.objects[0]
        expect(config_object).to be_a(ObjectDiff)
        expect(config_object.name).to eq('Config')
        expect(config_object.type).to eq('Added')
        expect(config_object.fields).to be_a(Array)
        expect(config_object.fields.length).to be(2)

        2.times do |i|
          expect(config_object.fields[i].annotations).to eq([])
          expect(config_object.fields[i].old).to eq('')
          expect(config_object.fields[i].type).to eq('Added')
        end

        expect(config_object.fields[0].name).to eq('args[0]')
        expect(config_object.fields[0].new).to eq('1000')
        expect(config_object.fields[1].name).to eq('command')
        expect(config_object.fields[1].new).to eq('/bin/sleep')

        resources_object = task_diff.objects[1]
        expect(resources_object).to be_a(ObjectDiff)
        expect(resources_object.name).to eq('Resources')
        expect(resources_object.type).to eq('Added')
        expect(resources_object.fields).to be_a(Array)
        expect(resources_object.fields.length).to be(4)
        4.times do |i|
          expect(resources_object.fields[i].annotations).to eq([])
          expect(resources_object.fields[i].old).to eq('')
          expect(resources_object.fields[i].type).to eq('Added')
        end
        expect(resources_object.fields[0].name).to eq('CPU')
        expect(resources_object.fields[0].new).to eq('20')
        expect(resources_object.fields[1].name).to eq('DiskMB')
        expect(resources_object.fields[1].new).to eq('0')
        expect(resources_object.fields[2].name).to eq('IOPS')
        expect(resources_object.fields[2].new).to eq('0')
        expect(resources_object.fields[3].name).to eq('MemoryMB')
        expect(resources_object.fields[3].new).to eq('12')

        resources_nested_objects = resources_object.objects
        expect(resources_nested_objects).to be_a(Array)
        expect(resources_nested_objects.length).to be(1)

        network_resource = resources_nested_objects[0]
        expect(network_resource).to be_a(ObjectDiff)
        expect(network_resource.name).to eq('Network')
        expect(network_resource.type).to eq('Added')
        expect(network_resource.fields[0].name).to eq('MBits')
        expect(network_resource.fields[0].new).to eq('1')
        expect(network_resource.fields[0].annotations).to eq([])
        expect(network_resource.fields[0].old).to eq('')
        expect(network_resource.fields[0].type).to eq('Added')

        network_nested_objects = network_resource.objects
        expect(network_nested_objects).to be_a(Array)
        expect(network_nested_objects.length).to eq(1)
      end
    end
  end
end
