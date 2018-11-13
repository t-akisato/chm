BEGIN {
}

$2 == "COOL" {
    c1 ++
    m[$1] ++
}

$2 == "HOT" {
    c2 ++
    m2[$1] ++
}

END {
    printf("COOL %4d\n", c1)
    printf("HOT  %4d\n", c2)
    for( map in m) {
	printf("%s %d\n", map, m[map])
    }
    for( map in m2) {
	if(m2[map] == 10) {
	    printf("%s 0\n", map)
	}
    }
}
    