package Classes::FabOS::Component::CpuSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  foreach (qw(swCpuUsage swCpuNoOfRetries swCpuUsageLimit swCpuPollingInterval
      swCpuAction)) {
    $self->{$_} = $self->valid_response('SW-MIB', $_, 0);
  }
  $self->get_snmp_objects('SW-MIB', (qw(
      swFwFabricWatchLicense)));
}

sub check {
  my $self = shift;
  $self->add_info('checking cpus');
  if (defined $self->{swCpuUsage}) {
    $self->add_info(sprintf 'cpu usage is %.2f%%', $self->{swCpuUsage});
    $self->set_thresholds(warning => $self->{swCpuUsageLimit},
        critical => $self->{swCpuUsageLimit});
    $self->add_message($self->check_thresholds($self->{swCpuUsage}));
    $self->add_perfdata(
        label => 'cpu_usage',
        value => $self->{swCpuUsage},
        uom => '%',
    );
  } elsif ($self->{swFwFabricWatchLicense} eq 'swFwNotLicensed') {
    $self->add_unknown('please install a fabric watch license');
  } else {
    my $swFirmwareVersion = $self->get_snmp_object('SW-MIB', 'swFirmwareVersion');
    if ($swFirmwareVersion && $swFirmwareVersion =~ /^v6/) {
      $self->add_ok('cpu usage is not implemented');
    } else {
      $self->add_unknown('cannot aquire cpu usage');
    }
  }
}

