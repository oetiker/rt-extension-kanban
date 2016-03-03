use strict;
use warnings;
use 5.010001;

package RT::Extension::KANBAN;

our $VERSION = '0.1';

RT->AddStyleSheets('tasks.css');

RT->AddJavaScript('md5.min.js');
RT->AddJavaScript('doT.min.js');
RT->AddJavaScript('jquery-ui.min.js');
RT->AddJavaScript('reconnecting-websocket.min.js');

my $components = RT->Config->Get('HomepageComponents');
RT->Config->Set('HomepageComponents', [@$components, 'Kanban']);

# Kanban view needs infos on tickets which have been changes
# so it can update these!
sub SendIDviaRedis  {
    my ($id) = $_[0];
    print STDERR "Ticket: ", $id, " was affected, sending update to redis 'rt-ticket-activity'\n";

#     my $s = "{ \"ticketChange\" : " . $id . " }";
    system("redis-cli", "PUBLISH", "rt-ticket-activity",$id);
}

# introspection on steroids! we extend lib/RT/Ticket.pm function 
# we tinker with their arguments and see if they execute well.
# just to get the ticket IDs in question ;-)
require RT::Ticket;
package RT::Ticket;

{
    my $orig = __PACKAGE__->can('Create')
        or die "It's not RT 4.2.12, you have to patch this RT."
            ." Read documentation for RT::Extension::RepliesToResolved";

    no warnings qw(redefine);

    *Create = sub {
        my $self = shift;
 
        my ($a, $b, $c) = $orig->($self, @_);
        &RT::Extension::KANBAN::SendIDviaRedis($a);
        return ($a, $b, $c);
    };
}


{
    my $orig = __PACKAGE__->can('MergeInto')
        or die "It's not RT 4.2.12, you have to patch this RT."
            ." Read documentation for RT::Extension::RepliesToResolved";

    no warnings qw(redefine);

    *MergeInto = sub {
        my $self = shift;
        my $ticket_id = shift;

        my $id1 = $self->Id;
        my $id2 = $ticket_id;

        my ($a, $b) = $orig->($self, $ticket_id);

        if ($a) {
          &RT::Extension::KANBAN::SendIDviaRedis($id1);
          &RT::Extension::KANBAN::SendIDviaRedis($id2);
        }
        return ($a, $b);
    };
}


{
    my $orig = __PACKAGE__->can('_Set')
        or die "It's not RT 4.2.12, you have to patch this RT."
            ." Read documentation for RT::Extension::RepliesToResolved";

    no warnings qw(redefine);

    *_Set = sub {
        my $self = shift;
        my $id = $self->Id;

        my ($a, $b) = $orig->($self, @_);
        &RT::Extension::KANBAN::SendIDviaRedis($id);
        return ($a, $b);
    };
}

1;