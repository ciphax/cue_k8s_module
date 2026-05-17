module: "example.com"
language: version: "v0.16.1"
deps: {
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.7.0"
		default: true
	}
	"ghcr.io/ciphax/cue_k8s_module@v1": {
		v: "v1.0.0"
	}
}
