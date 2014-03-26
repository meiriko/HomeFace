package homeface

import (
    "html/template"
    "net/http"
    // "net/url"
    "time"
	"fmt"
	// "os"
	// "strings"
	"strconv"
	"encoding/json"

    "appengine"
    "appengine/datastore"
    "appengine/urlfetch"
)

type HomeFaceResult struct {
	ImageUrl	string
	DX			float32
	DY			float32
	SX			float32
	SY			float32
	Title		string
	Points		string `datastore:",noindex"`
    Date    time.Time
}

type DrawingConfig struct {
    Title	string
	Config	string `datastore:",noindex"`
}

type HomeFaceListResults struct{
	Keys	[]*datastore.Key
	Vals	[]HomeFaceResult
}

type ConfigResults struct{
	Keys	[]*datastore.Key
	Vals	[]DrawingConfig
}

func init() {
    http.HandleFunc("/pt/", passThrough)

    http.HandleFunc("/show", showImage)
    http.HandleFunc("/images", listImages)
    http.HandleFunc("/imageData", getImageData)
    http.HandleFunc("/compareImages", compareImages)
    http.HandleFunc("/morph", morph)
    http.HandleFunc("/store", storeImage)

    http.HandleFunc("/config", showConfig)
    http.HandleFunc("/configs", listConfigs)
    http.HandleFunc("/configTitles", listConfigTitles)
    http.HandleFunc("/saveConfig", saveConfig)
    http.HandleFunc("/createConfig", createConfig)

    http.HandleFunc("/hf", goToHf)
    http.HandleFunc("/", goToHf)
}

const layout = "2/Jan 15:04"

var homeFaceImagesListTemplate = template.Must(template.ParseFiles("imagesList.tpl"))

var homeFaceImageTemplate = template.Must(template.ParseFiles("imageScaled.tpl"))

var homeFaceImagesCompareTemplate = template.Must(template.ParseFiles("imagesScaled.tpl"))

var homeFaceImagesCompareMorphTemplate = template.Must(template.ParseFiles("imagesScaledMorph.tpl"))

var homeFaceCreateConfigTemplate = template.Must(template.ParseFiles("createJsonConfig.tpl"))

var homeFaceConfigsListTemplate = template.Must(template.ParseFiles("configsList.tpl"))

var homeFaceConfigTitlesTemplate = template.Must(template.ParseFiles("configTitles.tpl"))

func (r HomeFaceResult) FormattedDate() string {
	return (r.Date.Format(layout))
}

func getFormValueAsFloat32(r *http.Request, key string) float32{
	value,_ := strconv.ParseFloat(r.FormValue(key),32)
	return float32(value)
}

// homefaceKey returns the key used for all guestbook entries.
func homefaceKey(c appengine.Context, id string) *datastore.Key {
    return datastore.NewKey(c, "Homeface", id, 0, nil)
}

func goToHf(w http.ResponseWriter, r *http.Request) {
    http.Redirect(w, r, "/app/homeface_tester.html", http.StatusFound)
}

func showConfig(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
	encodedKey := r.FormValue("key")
	key,_ := datastore.DecodeKey(encodedKey)
	var drawingConfig DrawingConfig
	err := datastore.Get(c, key, &drawingConfig)
	if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
	} else {
		jsonConfig, _ := json.Marshal(drawingConfig)
		fmt.Fprintln(w, string(jsonConfig))
	}
}

func getImageData(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
	encodedKey := r.FormValue("key")
	key,_ := datastore.DecodeKey(encodedKey)
	var hfr HomeFaceResult
	err := datastore.Get(c, key, &hfr)
	if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
	} else {
		jsonConfig, _ := json.Marshal(hfr)
		fmt.Fprintln(w, string(jsonConfig))
	}
}

func showImage(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
	encodedKey := r.FormValue("key")
	key,_ := datastore.DecodeKey(encodedKey)
	var hfr HomeFaceResult
	err := datastore.Get(c, key, &hfr)
	if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
	} else {
		if err := homeFaceImageTemplate.Execute(w, hfr); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}
	}
}

func listImages(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
    q := datastore.NewQuery("HomeFaceResult").Limit(10)
    results := make([]HomeFaceResult, 0, 10)
    keys, err := q.GetAll(c, &results)
	if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
	vals := HomeFaceListResults{
		Keys:	keys,
		Vals:	results,
	}
    if err := homeFaceImagesListTemplate.Execute(w, vals); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}

func compareImages(w http.ResponseWriter, r *http.Request) {
	// keys := strings.Split(r.FormValue("keys"), ",")
	// fmt.Fprintf(w, "keys: %s, len: %d", keys, len(keys))
	if err := homeFaceImagesCompareTemplate.Execute(w, nil); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func morph(w http.ResponseWriter, r *http.Request) {
	if err := homeFaceImagesCompareMorphTemplate.Execute(w, nil); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func listConfigs(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
    q := datastore.NewQuery("DrawingConfig").Limit(10)
    results := make([]DrawingConfig, 0, 10)
    _, err := q.GetAll(c, &results)
	if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    if err := homeFaceConfigsListTemplate.Execute(w, results); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}

func listConfigTitles(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
    q := datastore.NewQuery("DrawingConfig").Limit(20)
    results := make([]DrawingConfig, 0, 20)
    keys, err := q.GetAll(c, &results)
	vals := ConfigResults{
		Keys:	keys,
		Vals:	results,
	}
	if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
	// var buf bytes.Buffer
    if err := homeFaceConfigTitlesTemplate.Execute(w, vals); err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
    }
}


func passThrough(w http.ResponseWriter, r *http.Request) {
	c := appengine.NewContext(r)
	client := urlfetch.Client(c)
	resp, err := client.Get(r.URL.Path[4:])
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	buffer := make([]byte, resp.ContentLength)
	_, err1 := resp.Body.Read(buffer)
	if( err1 != nil ) {
		http.Error(w, err1.Error(), http.StatusInternalServerError)
	} else {
		w.Write(buffer)
	}
}

func storeImage(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
    hfr := HomeFaceResult{
		ImageUrl:	r.FormValue("imageUrl"),
		DX:			getFormValueAsFloat32(r, "dX"),
		DY:			getFormValueAsFloat32(r, "dY"),
		SX:			getFormValueAsFloat32(r, "sX"),
		SY:			getFormValueAsFloat32(r, "sY"),
		Points:		r.FormValue("points"),
		Title:		r.FormValue("title"),
        Date:		time.Now(),
    }
    // We set the same parent key on every Greeting entity to ensure each Greeting
    // is in the same entity group. Queries across the single entity group
    // will be consistent. However, the write rate to a single entity group
    // should be limited to ~1/second.
    key := datastore.NewIncompleteKey(c, "HomeFaceResult", homefaceKey(c, "image"))
    newKey, err := datastore.Put(c, key, &hfr)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
	fmt.Fprintln(w, newKey)
    //http.Redirect(w, r, "/hf", http.StatusFound)
}

func saveConfig(w http.ResponseWriter, r *http.Request) {
    c := appengine.NewContext(r)
    config := DrawingConfig{
		Title:		r.FormValue("title"),
		Config:		r.FormValue("content"),
    }
    key := datastore.NewIncompleteKey(c, "DrawingConfig", homefaceKey(c, "config"))
    newKey, err := datastore.Put(c, key, &config)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
	fmt.Fprintln(w, newKey.Encode())
    // http.Redirect(w, r, "/hf", http.StatusFound)
}

func createConfig(w http.ResponseWriter, r *http.Request) {
    // c := appengine.NewContext(r)
	if err := homeFaceCreateConfigTemplate.Execute(w, nil); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
