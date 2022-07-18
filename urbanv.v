import net.http
import os
import json

struct JsonStruct {
	list []struct {
		definition string
		example string
		word string
	}
}

const (
	urban_api_url = "https://api.urbandictionary.com/v0/define?term="
	urban_rand_api_url = "https://api.urbandictionary.com/v0/random"
)

fn req(api_url string, arg string) ? (JsonStruct, int) {
	data := http.get("${api_url}${arg}")?
	json := json.decode(JsonStruct, data.body)?
	if data.status_code != 200 || json.list.len == 0 {
		return json, 1
	}
	return json, 0
}

fn rand_req(api_url string) ? JsonStruct {
	data := http.get("${api_url}")?
	json := json.decode(JsonStruct, data.body)?
	return json
}

fn help() {
	println(
"urbanv v0.2
Usage:
urban [options] [word]

Options:
-h, shows help menu
-q, query a word or text
-e, examples of a word or text
-r, random definitions or examples, use '-q' or '-e' after this param")
}

fn main() {
	args := os.args.clone()
	match args[1] {
		"-q" {
			if args.len < 3 {
				println("error: please provide a query")
				return
			}
			if args[2] != "-r" {
				json, err := req(urban_api_url, args[2..].join(" "))?
				if err == 1 {
					println("error: no results found according your query")
					return
				}
				print("\033[1;95m\t\t\tꢭ Definitions of ${args[2..].join(" ").title()} ꢭ\033[0m\n\n")
				for i := 0; i < json.list.len; i++ {
					println("\033[0;33m•\033[0m ${json.list[i].definition}\n")
				}
			} else {
				json := rand_req(urban_rand_api_url)?
				for i := 0; i < json.list.len; i++ {
					println("• \033[0;32m${json.list[i].word} \033[0;33m~\033[0m ${json.list[i].definition}\n")
				}
			}
		}
		"-e" {
			if args.len < 3 {
				println("error: please provide a query")
				return
			}
			if args[2] != "-r" {
				json, err := req(urban_api_url, args[2..].join(" "))?
				if err == 1 {
					println("error: no results found according your query")
					return
				}
				print("\033[1;95m\t\t\tꢭ Definitions of ${args[2..].join(" ").title()} ꢭ\033[0m\n\n")
				for i := 0; i < json.list.len; i++ {
					println("\033[0;33m•\033[0m ${json.list[i].example}\n")
				}
			} else {
				json := rand_req(urban_rand_api_url)?
				for i := 0; i < json.list.len; i++ {
					println("• \033[0;32m${json.list[i].word} \033[0;33m~\033[0m ${json.list[i].example}\n")
				}
			}
		}
		"-r" {
			if args.len == 3 && args[2] == "-e" {
				json_e := rand_req(urban_rand_api_url)?
				for i := 0; i < json_e.list.len; i++ {
					println("• \033[0;32m${json_e.list[i].word} \033[0;33m~\033[0m ${json_e.list[i].example}\n")
				}
				return
			}
			json := rand_req(urban_rand_api_url)?
			for i := 0; i < json.list.len; i++ {
				println("• \033[0;32m${json.list[i].word} \033[0;33m~\033[0m ${json.list[i].definition}\n")
			}
		}
		"-h" {
			help()
		}
		else {
			help()
		}
	}
}
