package main

import (
	"cloud.google.com/go/translate"
	"context"
	"fmt"
	"golang.org/x/text/language"
	"net/http"
)

var langMap = map[string]string{"Afrikaans": "af", "Albanian": "sq", "Amharic": "am", "Arabic": "ar", "Armenian": "hy", "Assamese": "as", "Aymara": "ay", "Azerbaijani": "az", "Bambara": "bm", "Basque": "eu", "Belarusian": "be", "Bengali": "bn", "Bhojpuri": "bho", "Bosnian": "bs", "Bulgarian": "bg", "Catalan": "ca", "Cebuano": "ceb", "Chinese (Simplified)": "zh", "Chinese (Traditional)": "zh-TW", "Corsican": "co", "Croatian": "hr", "Czech": "cs", "Danish": "da", "Dhivehi": "dv", "Dogri": "doi", "Dutch": "nl", "English": "en", "Esperanto": "eo", "Estonian": "et", "Ewe": "ee", "Filipino (Tagalog)": "fil", "Finnish": "fi", "French": "fr", "Frisian": "fy", "Galician": "gl", "Georgian": "ka", "German": "de", "Greek": "el", "Guarani": "gn", "Gujarati": "gu", "Haitian Creole": "ht", "Hausa": "ha", "Hawaiian": "haw", "Hebrew": "he or iw", "Hindi": "hi", "Hmong": "hmn", "Hungarian": "hu", "Icelandic": "is", "Igbo": "ig", "Ilocano": "ilo", "Indonesian": "id", "Irish": "ga", "Italian": "it", "Japanese": "ja", "Javanese": "jv", "Kannada": "kn", "Kazakh": "kk", "Khmer": "km", "Kinyarwanda": "rw", "Konkani": "gom", "Korean": "ko", "Krio": "kri", "Kurdish": "ku", "Kyrgyz": "ky", "Lao": "lo", "Latin": "la", "Latvian": "lv", "Lingala": "ln", "Lithuanian": "lt", "Luganda": "lg", "Luxembourgish": "lb", "Macedonian": "mk", "Maithili": "mai", "Malagasy": "mg", "Malay": "ms", "Malayalam": "ml", "Maltese": "mt", "Maori": "mi", "Marathi": "mr", "Meiteilon": "mni-Mtei", "Mizo": "lus", "Mongolian": "mn", "Myanmar": "my", "Nepali": "ne", "Norwegian": "no", "Nyanja": "ny", "Odia": "or", "Oromo": "om", "Pashto": "ps", "Persian": "fa", "Polish": "pl", "Portuguese": "pt", "Punjabi": "pa", "Quechua": "qu", "Romanian": "ro", "Russian": "ru", "Samoan": "sm", "Sanskrit": "sa", "Scots Gaelic": "gd", "Sepedi": "nso", "Serbian": "sr", "Sesotho": "st", "Shona": "sn", "Sindhi": "sd", "Sinhala": "si", "Slovak": "sk", "Slovenian": "sl", "Somali": "so", "Spanish": "es", "Sundanese": "su", "Swahili": "sw", "Swedish": "sv", "Tagalog": "tl", "Tajik": "tg", "Tamil": "ta", "Tatar": "tt", "Telugu": "te", "Thai": "th", "Tigrinya": "ti", "Tsonga": "ts", "Turkish": "tr", "Turkmen": "tk", "Twi": "ak", "Ukrainian": "uk", "Urdu": "ur", "Uyghur": "ug", "Uzbek": "uz", "Vietnamese": "vi", "Welsh": "cy", "Xhosa": "xh", "Yiddish": "yi", "Yoruba": "yo", "Zulu": "zu"}

func (app *api) translateText(w http.ResponseWriter, r *http.Request) {
	text := "The Go Gopher is cute"
	targetLanguage := "French"
	ctx := context.Background()

	lang, err := language.Parse(langMap[targetLanguage])
	if err != nil {
		app.serverErrorResponse(w, r, fmt.Errorf("language.Parse: %w", err))
		return
	}

	client, err := translate.NewClient(ctx)
	if err != nil {
		app.serverErrorResponse(w, r, err)
		return
	}
	defer client.Close()

	resp, err := client.Translate(ctx, []string{text}, lang, nil)
	if err != nil {
		app.serverErrorResponse(w, r, fmt.Errorf("Translate: %w", err))
		return
	}
	if len(resp) == 0 {
		app.serverErrorResponse(w, r, fmt.Errorf("translate returned empty response to text: %s", text))
		return
	}
	app.Logger.PrintInfo(resp[0].Text, nil)
	// Send the user a confirmation message.
	env := envelope{"translation": resp[0].Text}

	err = app.writeJSON(w, http.StatusOK, env, nil)
	if err != nil {
		app.serverErrorResponse(w, r, err)
	}
}
