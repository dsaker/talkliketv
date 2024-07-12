package main

import (
	"context"
	"fmt"

	"cloud.google.com/go/translate"
	"golang.org/x/text/language"
)

func main() {
	text := "Te va a encantar ser su nana Son unos angelitos. - Ay, se portan tan bien mis hijos. Los amo. - Yo creo que llego a la presentació como 15 minutos tarde. - Ay, mamá, ella empezó metió mis zapatos al excusado. - No lo tomes personal. - que probaras el pastel. - No llego a la junta. - No, perdóneme, señor Rizo. Ahorita llego. - Es que me quedé resolviend una cosa con el banco, y… - Entonces, ¿sí tiene experiencia uste con niños… inquietos? - Le juro que es de plástico. Se lo juro. - Señor Rizo… no llego. - para la despedida de mi papá? - la mera jefa de la empresa? - Solo falta termina la propuesta financiera - que voy a presentar al consej y conseguir una buena nana. - Ya salte de esa cocina, por favor Te veo en tu oficina. - Leo, incendiarás la cas y a los de adentro. - Solo era un experimento, mamá y nadie quiere vivir hasta los 40. - Muchos sí, pero seguro tú no."
	ctx := context.Background()

	lang, err := language.Parse("en")
	if err != nil {
		println(fmt.Errorf("language.Parse: %w", err))
	}

	client, err := translate.NewClient(ctx)
	if err != nil {
		println(fmt.Errorf("error creating client: %s", err))
	}
	defer client.Close()

	resp, err := client.Translate(ctx, []string{text}, lang, nil)
	if err != nil {
		println(fmt.Errorf("translate: %w", err))
	}
	if len(resp) == 0 {
		println(fmt.Errorf("translate returned empty response to text: %s", text))
	}
	println(resp[0].Text)
}
