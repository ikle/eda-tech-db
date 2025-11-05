#!/usr/bin/perl

sub pull ($) {
	my ($from) = @_;
	my $line = <$from>;

	return undef unless defined $line;
	chomp $line;
	return $line;
}

sub convert_path ($$$$$$) {
	my ($to, $cell, $variant, $path, $delay, $load) = @_;
	my ($source, $sink, $dir) = split (/-/, $path);

	die "E: Cannot find path source\n"	unless (defined $source and $source ne '');
	die "E: Cannot find path sink\n"	unless (defined $sink   and $sink   ne '');
	die "E: Cannot find path direction\n"	unless (defined $dir    and $dir    ne '');

	$delay = int ($delay * 1000);
	$load  = int ($load  * 1000);

	print $to "$cell,$variant,$source,$sink,$dir,$delay,$load\n";
}

sub convert_variant ($$$$) {
	my ($to, $head, $delays, $loads) = @_;
	my @H = split (/\s+/, $head);
	my @D = split (/\s+/, $delays);
	my @L = split (/\s+/, $loads);

	die "E: Unit without paths\n" if scalar @H < 2;
	die "E: Wrong entry count in delay line\n" if scalar @H != scalar @D;
	die "E: Wrong entry count in load line\n"  if scalar @H != scalar @L;
	die "E: Broken variant name: $D[0] != $L[0]\n" if $D[0] ne $L[0];

	for (my $i = 1; $i < scalar @H; ++$i) {
		convert_path ($to, $H[0], $D[0], $H[$i], $D[$i], $L[$i]);
	}
}

sub convert_one ($$) {
	my ($from, $to) = @_;
	my $head = pull ($from);
	my @delay = ();
	my @load  = ();

	return 0 unless defined $head;

	die "E: Header is empty\n" if $head eq '';

	my $s = pull ($from);

	die "E: Empty line expected after header\n" unless (defined $s and $s eq '');

	while (1) {
		$s = pull ($from);

		die "E: Unexpected EOF in delay list\n" unless defined $s;

		last if $s eq '';

		push @delay, $s;
	}

	while (1) {
		$s = pull ($from);

		die "E: Unexpected EOF in load list\n" unless defined $s;

		last if $s eq '';

		push @load, $s;
	}

	die "E: Empty delay list\n" if scalar @delay == 0;
	die "E: Empty load list\n"  if scalar @load  == 0;
	die "E: Delay and load list of different size\n"
	if scalar @delay != scalar @load == 0;

	for (my $i = 0; $i < scalar @delay; ++$i) {
		convert_variant ($to, $head, $delay[$i], $load[$i]);
	}

	return 1;
}

my $from = STDIN;
my $to   = STDOUT;

print $to "cell,variant,source,sink,dir,delay,load\n";

while (convert_one ($from, $to)) {}

