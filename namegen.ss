;;; namegen.el --- fantasy name generator

;; This is free and unencumbered software released into the public domain.

;;; Commentary:

;; This is mostly just some thoughts on an elisp name generator. Is it
;; based on the RinkWorks generator, though none of the syntax is
;; specifically used, only sexps. Symbols are replaced by a random
;; selection from its group,

;; s  syllable
;; v  single vowel
;; V  single vowel or vowel combination
;; c  single consonant
;; B  single consonant or consonant combination suitable for beginning a word
;; C  single consonant or consonant combination suitable anywhere in a word
;; i  an insult
;; m  a mushy name
;; M  a mushy name ending
;; n  a name
;; a  an adjective
;; sw a star wars name
;; D  consonant suited for a stupid person's name
;; d  syllable suited for a stupid person's name (always begins with a vowel)

;; Strings are literal and passed in verbatim. If a list is presented,
;; select one of it's elements of random to be generated.
;;
;; So, to generate a name beginning with a syllable, then "ith" or a '
;; followed by a constant, and ending in a vowel sound,

;;    (s ("ith" ("'" C)) V)

;; In the RinkWorks syntax it would be,

;;    s(ith|<'C>)V

;; Just call it with namegen,

;;    (namegen '(s ("ith" ("'" C)) V))

;; And it generates a string with a name.

;;; Code:
(import :gerbil/gambit
        :std/format)

(export namegen)

(def namegen-subs
     ;; Substitutions for the name generator.
     '((s ach ack ad age ald ale an ang ar ard as ash at ath augh
          aw ban bel bur cer cha che dan dar del den dra dyn
          ech eld elm em en end eng enth er ess est et gar gha
          hat hin hon ia ight ild im ina ine ing ir is iss it
          kal kel kim kin ler lor lye mor mos nal ny nys old om
          on or orm os ough per pol qua que rad rak ran ray ril
          ris rod roth ryn sam say ser shy skel sul tai tan tas
          ther tia tin ton tor tur um und unt urn usk ust ver
          ves vor war wor yer)
       (v a e i o u y)
       (V a e i o u y ae ai au ay ea ee ei eu ey ia ie oe oi oo ou
          ui)
       (c b c d f g h j k l m n p q r s t v w x y z)
       (B b bl br c ch chr cl cr d dr f g h j k l ll m n p ph qu r
          rh s sch sh sl sm sn st str sw t th thr tr v w wh y z zh)
       (C b c ch ck d f g gh h k l ld ll lt m n nd nn nt p ph q r rd
          rr rt s sh ss st t th v w y z)
       (i air ankle ball beef bone bum bumble bump cheese clod clot clown corn
          dip dolt doof dork dumb face finger foot fumble goof grumble head knock knocker
          knuckle loaf lump lunk meat muck munch nit numb pin puff skull snark sneeze
          thimble twerp twit wad wimp wipe)
       (n aaren aarika abagael abagail abbe abbey abbi
          abbie abby abbye abigael abigail abigale abra ada adah adaline adan adara adda
          addi addia addie addy adel adela adelaida adelaide adele adelheid adelice
          adelina adelind adeline adella adelle adena adey adi adiana adina adora adore
          adoree adorne adrea adria adriaens adrian adriana adriane adrianna adrianne
          adriena adrienne aeriel aeriela aeriell afton ag agace agata agatha agathe aggi
          aggie aggy agna agnella agnes agnese agnesse agneta agnola agretha aida aidan
          aigneis aila aile ailee aileen ailene ailey aili ailina ailis ailsun ailyn aime
          aimee aimil aindrea ainslee ainsley ainslie ajay alaine alameda alana alanah
          alane alanna alayne alberta albertina albertine albina alecia aleda aleece aleen
          alejandra alejandrina alena alene alessandra aleta alethea alex alexa alexandra
          alexandrina alexi alexia alexina alexine alexis alfi alfie alfreda alfy ali alia
          alica alice alicea alicia alida alidia alie alika alikee alina aline alis alisa
          alisha alison alissa alisun alix aliza alla alleen allegra allene alli allianora
          allie allina allis allison allissa allix allsun allx ally allyce allyn allys
          allyson alma almeda almeria almeta almira almire aloise aloisia aloysia alta
          althea alvera alverta alvina alvinia alvira alyce alyda alys alysa alyse alysia
          alyson alyss alyssa amabel amabelle amalea amalee amaleta amalia amalie amalita
          amalle amanda amandi amandie amandy amara amargo amata amber amberly ambur ame
          amelia amelie amelina ameline amelita ami amie amii amil amitie amity ammamaria
          amy amye ana anabal anabel anabella anabelle analiese analise anallese anallise
          anastasia anastasie anastassia anatola andee andeee anderea andi andie andra
          andrea andreana andree andrei andria andriana andriette andromache andy
          anestassia anet anett anetta anette ange angel angela angele angelia angelica
          angelika angelina angeline angelique angelita angelle angie angil angy ania
          anica anissa anita anitra anjanette anjela ann ann-marie anna anna-diana
          anna-diane anna-maria annabal annabel annabela annabell annabella annabelle
          annadiana annadiane annalee annaliese annalise annamaria annamarie anne
          anne-corinne anne-marie annecorinne anneliese annelise annemarie annetta annette
          anni annice annie annis annissa annmaria annmarie annnora annora anny anselma
          ansley anstice anthe anthea anthia anthiathia antoinette antonella antonetta
          antonia antonie antonietta antonina anya appolonia april aprilette ara arabel
          arabela arabele arabella arabelle arda ardath ardeen ardelia ardelis ardella
          ardelle arden ardene ardenia ardine ardis ardisj ardith ardra ardyce ardys
          ardyth aretha ariadne ariana aridatha ariel ariela ariella arielle arlana arlee
          arleen arlen arlena arlene arleta arlette arleyne arlie arliene arlina arlinda
          arline arluene arly arlyn arlyne aryn ashely ashia ashien ashil ashla ashlan
          ashlee ashleigh ashlen ashley ashli ashlie ashly asia astra astrid astrix
          atalanta athena athene atlanta atlante auberta aubine aubree aubrette aubrey
          aubrie aubry audi audie audra audre audrey audrie audry audrye audy augusta
          auguste augustina augustine aundrea aura aurea aurel aurelea aurelia aurelie
          auria aurie aurilia aurlie auroora aurora aurore austin austina austine ava
          aveline averil averyl avie avis aviva avivah avril avrit ayn bab babara babb
          babbette babbie babette babita babs bambi bambie bamby barb barbabra barbara
          barbara-anne barbaraanne barbe barbee barbette barbey barbi barbie barbra barby
          bari barrie barry basia bathsheba batsheva bea beatrice beatrisa beatrix beatriz
          bebe becca becka becki beckie becky bee beilul beitris bekki bel belia belicia
          belinda belita bell bella bellanca belle bellina belva belvia bendite benedetta
          benedicta benedikta benetta benita benni bennie benny benoite berenice beret
          berget berna bernadene bernadette bernadina bernadine bernardina bernardine
          bernelle bernete bernetta bernette berni bernice bernie bernita berny berri
          berrie berry bert berta berte bertha berthe berti bertie bertina bertine berty
          beryl beryle bess bessie bessy beth bethanne bethany bethena bethina betsey
          betsy betta bette bette-ann betteann betteanne betti bettina bettine betty
          bettye beulah bev beverie beverlee beverley beverlie beverly bevvy bianca bianka
          bibbie bibby bibbye bibi biddie biddy bidget bili bill billi billie billy billye
          binni binnie binny bird birdie birgit birgitta blair blaire blake blakelee
          blakeley blanca blanch blancha blanche blinni blinnie blinny bliss blisse blithe
          blondell blondelle blondie blondy blythe bobbe bobbee bobbette bobbi bobbie
          bobby bobbye bobette bobina bobine bobinette bonita bonnee bonni bonnibelle
          bonnie bonny brana brandais brande brandea brandi brandice brandie brandise
          brandy breanne brear bree breena bren brena brenda brenn brenna brett bria
          briana brianna brianne bride bridget bridgette bridie brier brietta brigid
          brigida brigit brigitta brigitte brina briney brinn brinna briny brit brita
          britney britni britt britta brittan brittaney brittani brittany britte britteny
          brittne brittney brittni brook brooke brooks brunhilda brunhilde bryana bryn
          bryna brynn brynna brynne buffy bunni bunnie bunny cacilia cacilie cahra
          cairistiona caitlin caitrin cal calida calla calley calli callida callie cally
          calypso cam camala camel camella camellia cami camila camile camilla camille
          cammi cammie cammy candace candi candice candida candide candie candis candra
          candy caprice cara caralie caren carena caresa caressa caresse carey cari caria
          carie caril carilyn carin carina carine cariotta carissa carita caritta carla
          carlee carleen carlen carlene carley carlie carlin carlina carline carlita
          carlota carlotta carly carlye carlyn carlynn carlynne carma carmel carmela
          carmelia carmelina carmelita carmella carmelle carmen carmencita carmina carmine
          carmita carmon caro carol carol-jean carola carolan carolann carole carolee
          carolin carolina caroline caroljean carolyn carolyne carolynn caron carree carri
          carrie carrissa carroll carry cary caryl caryn casandra casey casi casie cass
          cassandra cassandre cassandry cassaundra cassey cassi cassie cassondra cassy
          catarina cate caterina catha catharina catharine cathe cathee catherin catherina
          catherine cathi cathie cathleen cathlene cathrin cathrine cathryn cathy
          cathyleen cati catie catina catlaina catlee catlin catrina catriona caty caye
          cayla cecelia cecil cecile ceciley cecilia cecilla cecily ceil cele celene
          celesta celeste celestia celestina celestine celestyn celestyna celia celie
          celina celinda celine celinka celisse celka celle cesya chad chanda chandal
          chandra channa chantal chantalle charil charin charis charissa charisse charita
          charity charla charlean charleen charlena charlene charline charlot charlotta
          charlotte charmain charmaine charmane charmian charmine charmion charo charyl
          chastity chelsae chelsea chelsey chelsie chelsy cher chere cherey cheri
          cherianne cherice cherida cherie cherilyn cherilynn cherin cherise cherish
          cherlyn cherri cherrita cherry chery cherye cheryl cheslie chiarra chickie
          chicky chiquia chiquita chlo chloe chloette chloris chris chrissie chrissy
          christa christabel christabella christal christalle christan christean christel
          christen christi christian christiana christiane christie christin christina
          christine christy christye christyna chrysa chrysler chrystal chryste chrystel
          cicely cicily ciel cilka cinda cindee cindelyn cinderella cindi cindie cindra
          cindy cinnamon cissiee cissy clair claire clara clarabelle clare claresta
          clareta claretta clarette clarey clari claribel clarice clarie clarinda clarine
          clarissa clarisse clarita clary claude claudelle claudetta claudette claudia
          claudie claudina claudine clea clem clemence clementia clementina clementine
          clemmie clemmy cleo cleopatra clerissa clio clo cloe cloris clotilda clovis
          codee codi codie cody coleen colene coletta colette colleen collen collete
          collette collie colline colly con concettina conchita concordia conni connie
          conny consolata constance constancia constancy constanta constantia constantina
          constantine consuela consuelo cookie cora corabel corabella corabelle coral
          coralie coraline coralyn cordelia cordelie cordey cordi cordie cordula cordy
          coreen corella corenda corene coretta corette corey cori corie corilla corina
          corine corinna corinne coriss corissa corliss corly cornela cornelia cornelle
          cornie corny correna correy corri corrianne corrie corrina corrine corrinne
          corry cortney cory cosetta cosette costanza courtenay courtnay courtney crin
          cris crissie crissy crista cristabel cristal cristen cristi cristie cristin
          cristina cristine cristionna cristy crysta crystal crystie cthrine cyb cybil
          cybill cymbre cynde cyndi cyndia cyndie cyndy cynthea cynthia cynthie cynthy
          dacey dacia dacie dacy dael daffi daffie daffy dagmar dahlia daile daisey daisi
          daisie daisy dale dalenna dalia dalila dallas daloris damara damaris damita dana
          danell danella danette dani dania danica danice daniela daniele daniella
          danielle danika danila danit danita danna danni dannie danny dannye danya
          danyelle danyette daphene daphna daphne dara darb darbie darby darcee darcey
          darci darcie darcy darda dareen darell darelle dari daria darice darla darleen
          darlene darline darlleen daron darrelle darryl darsey darsie darya daryl daryn
          dasha dasi dasie dasya datha daune daveen daveta davida davina davine davita
          dawn dawna dayle dayna ddene de deana deane deanna deanne deb debbi debbie debby
          debee debera debi debor debora deborah debra dede dedie dedra dee deeann deeanne
          deedee deena deerdre deeyn dehlia deidre deina deirdre del dela delcina delcine
          delia delila delilah delinda dell della delly delora delores deloria deloris
          delphine delphinia demeter demetra demetria demetris dena deni denice denise
          denna denni dennie denny deny denys denyse deonne desdemona desirae desiree
          desiri deva devan devi devin devina devinne devon devondra devonna devonne
          devora di diahann dian diana diandra diane diane-marie dianemarie diann dianna
          dianne diannne didi dido diena dierdre dina dinah dinnie dinny dion dione dionis
          dionne dita dix dixie dniren dode dodi dodie dody doe doll dolley dolli dollie
          dolly dolores dolorita doloritas domeniga dominga domini dominica dominique dona
          donella donelle donetta donia donica donielle donna donnamarie donni donnie
          donny dora doralia doralin doralyn doralynn doralynne dore doreen dorelia
          dorella dorelle dorena dorene doretta dorette dorey dori doria dorian dorice
          dorie dorine doris dorisa dorise dorita doro dorolice dorolisa dorotea doroteya
          dorothea dorothee dorothy dorree dorri dorrie dorris dorry dorthea dorthy dory
          dosi dot doti dotti dottie dotty dre dreddy dredi drona dru druci drucie drucill
          drucy drusi drusie drusilla drusy dulce dulcea dulci dulcia dulciana dulcie
          dulcine dulcinea dulcy dulsea dusty dyan dyana dyane dyann dyanna dyanne dyna
          dynah eachelle eada eadie eadith ealasaid eartha easter eba ebba ebonee ebony
          eda eddi eddie eddy ede edee edeline eden edi edie edin edita edith editha
          edithe ediva edna edwina edy edyth edythe effie eileen eilis eimile eirena
          ekaterina elaina elaine elana elane elayne elberta elbertina elbertine eleanor
          eleanora eleanore electra eleen elena elene eleni elenore eleonora eleonore
          elfie elfreda elfrida elfrieda elga elianora elianore elicia elie elinor elinore
          elisa elisabet elisabeth elisabetta elise elisha elissa elita eliza elizabet
          elizabeth elka elke ella elladine elle ellen ellene ellette elli ellie ellissa
          elly ellyn ellynn elmira elna elnora elnore eloisa eloise elonore elora elsa
          elsbeth else elset elsey elsi elsie elsinore elspeth elsy elva elvera elvina
          elvira elwira elyn elyse elysee elysha elysia elyssa em ema emalee emalia emelda
          emelia emelina emeline emelita emelyne emera emilee emili emilia emilie emiline
          emily emlyn emlynn emlynne emma emmalee emmaline emmalyn emmalynn emmalynne
          emmeline emmey emmi emmie emmy emmye emogene emyle emylee engracia enid enrica
          enrichetta enrika enriqueta eolanda eolande eran erda erena erica ericha ericka
          erika erin erina erinn erinna erma ermengarde ermentrude ermina erminia erminie
          erna ernaline ernesta ernestine ertha eryn esma esmaria esme esmeralda essa
          essie essy esta estel estele estell estella estelle ester esther estrella
          estrellita ethel ethelda ethelin ethelind etheline ethelyn ethyl etta etti ettie
          etty eudora eugenia eugenie eugine eula eulalie eunice euphemia eustacia eva
          evaleen evangelia evangelin evangelina evangeline evania evanne eve eveleen
          evelina eveline evelyn evey evie evita evonne evvie evvy evy eyde eydie
          ezmeralda fae faina faith fallon fan fanchette fanchon fancie fancy fanechka
          fania fanni fannie fanny fanya fara farah farand farica farra farrah farrand
          faun faunie faustina faustine fawn fawne fawnia fay faydra faye fayette fayina
          fayre fayth faythe federica fedora felecia felicdad felice felicia felicity
          felicle felipa felisha felita feliza fenelia feodora ferdinanda ferdinande fern
          fernanda fernande fernandina ferne fey fiann fianna fidela fidelia fidelity fifi
          fifine filia filide filippa fina fiona fionna fionnula fiorenze fleur fleurette
          flo flor flora florance flore florella florence florencia florentia florenza
          florette flori floria florida florie florina florinda floris florri florrie
          florry flory flossi flossie flossy flss fran francene frances francesca francine
          francisca franciska francoise francyne frank frankie franky franni frannie
          franny frayda fred freda freddi freddie freddy fredelia frederica fredericka
          frederique fredi fredia fredra fredrika freida frieda friederike fulvia gabbey
          gabbi gabbie gabey gabi gabie gabriel gabriela gabriell gabriella gabrielle
          gabriellia gabrila gaby gae gael gail gale galina garland garnet garnette gates
          gavra gavrielle gay gaye gayel gayla gayle gayleen gaylene gaynor gelya gena
          gene geneva genevieve genevra genia genna genni gennie gennifer genny genovera
          genvieve george georgeanna georgeanne georgena georgeta georgetta georgette
          georgia georgiana georgianna georgianne georgie georgina georgine geralda
          geraldine gerda gerhardine geri gerianna gerianne gerladina germain germaine
          germana gerri gerrie gerrilee gerry gert gerta gerti gertie gertrud gertruda
          gertrude gertrudis gerty giacinta giana gianina gianna gigi gilberta gilberte
          gilbertina gilbertine gilda gilemette gill gillan gilli gillian gillie gilligan
          gilly gina ginelle ginevra ginger ginni ginnie ginnifer ginny giorgia giovanna
          gipsy giralda gisela gisele gisella giselle giuditta giulia giulietta giustina
          gizela glad gladi gladys gleda glen glenda glenine glenn glenna glennie glennis
          glori gloria gloriana gloriane glory glyn glynda glynis glynnis gnni godiva
          golda goldarina goldi goldia goldie goldina goldy grace gracia gracie grata
          gratia gratiana gray grayce grazia greer greta gretal gretchen grete gretel
          grethel gretna gretta grier griselda grissel guendolen guenevere guenna
          guglielma gui guillema guillemette guinevere guinna gunilla gus gusella gussi
          gussie gussy gusta gusti gustie gusty gwen gwendolen gwendolin gwendolyn gweneth
          gwenette gwenneth gwenni gwennie gwenny gwenora gwenore gwyn gwyneth gwynne
          gypsy hadria hailee haily haleigh halette haley hali halie halimeda halley halli
          hallie hally hana hanna hannah hanni hannie hannis hanny happy harlene harley
          harli harlie harmonia harmonie harmony harri harrie harriet harriett harrietta
          harriette harriot harriott hatti hattie hatty hayley hazel heath heather heda
          hedda heddi heddie hedi hedvig hedvige hedwig hedwiga hedy heida heidi heidie
          helaina helaine helen helen-elizabeth helena helene helenka helga helge helli
          heloise helsa helyn hendrika henka henrie henrieta henrietta henriette henryetta
          hephzibah hermia hermina hermine herminia hermione herta hertha hester hesther
          hestia hetti hettie hetty hilary hilda hildagard hildagarde hilde hildegaard
          hildegarde hildy hillary hilliary hinda holli hollie holly holly-anne hollyanne
          honey honor honoria hope horatia hortense hortensia hulda hyacinth hyacintha
          hyacinthe hyacinthia hyacinthie hynda ianthe ibbie ibby ida idalia idalina
          idaline idell idelle idette ileana ileane ilene ilise ilka illa ilsa ilse ilysa
          ilyse ilyssa imelda imogen imogene imojean ina indira ines inesita inessa inez
          inga ingaberg ingaborg inge ingeberg ingeborg inger ingrid ingunna inna iolande
          iolanthe iona iormina ira irena irene irina iris irita irma isa isabel isabelita
          isabella isabelle isadora isahella iseabal isidora isis isobel issi issie issy
          ivett ivette ivie ivonne ivory ivy izabel jacenta jacinda jacinta jacintha
          jacinthe jackelyn jacki jackie jacklin jacklyn jackquelin jackqueline jacky
          jaclin jaclyn jacquelin jacqueline jacquelyn jacquelynn jacquenetta jacquenette
          jacquetta jacquette jacqui jacquie jacynth jada jade jaime jaimie jaine jami
          jamie jamima jammie jan jana janaya janaye jandy jane janean janeczka janeen
          janel janela janella janelle janene janenna janessa janet janeta janetta janette
          janeva janey jania janice janie janifer janina janine janis janith janka janna
          jannel jannelle janot jany jaquelin jaquelyn jaquenetta jaquenette jaquith
          jasmin jasmina jasmine jayme jaymee jayne jaynell jazmin jean jeana jeane
          jeanelle jeanette jeanie jeanine jeanna jeanne jeannette jeannie jeannine
          jehanna jelene jemie jemima jemimah jemmie jemmy jen jena jenda jenelle jeni
          jenica jeniece jenifer jeniffer jenilee jenine jenn jenna jennee jennette jenni
          jennica jennie jennifer jennilee jennine jenny jeralee jere jeri jermaine jerrie
          jerrilee jerrilyn jerrine jerry jerrylee jess jessa jessalin jessalyn jessamine
          jessamyn jesse jesselyn jessi jessica jessie jessika jessy jewel jewell jewelle
          jill jillana jillane jillayne jilleen jillene jilli jillian jillie jilly jinny
          jo jo-ann jo-anne joan joana joane joanie joann joanna joanne joannes jobey jobi
          jobie jobina joby jobye jobyna jocelin joceline jocelyn jocelyne jodee jodi
          jodie jody joeann joela joelie joell joella joelle joellen joelly joellyn
          joelynn joete joey johanna johannah johna johnath johnette johnna joice jojo
          jolee joleen jolene joletta joli jolie joline joly jolyn jolynn jonell joni
          jonie jonis jordain jordan jordana jordanna jorey jori jorie jorrie jorry
          joscelin josee josefa josefina josepha josephina josephine josey josi josie
          josselyn josy jourdan joy joya joyan joyann joyce joycelin joye jsandye juana
          juanita judi judie judith juditha judy judye juieta julee juli julia juliana
          juliane juliann julianna julianne julie julienne juliet julieta julietta
          juliette julina juline julissa julita june junette junia junie junina justina
          justine justinn jyoti kacey kacie kacy kaela kai kaia kaila kaile kailey kaitlin
          kaitlyn kaitlynn kaja kakalina kala kaleena kali kalie kalila kalina kalinda
          kalindi kalli kally kameko kamila kamilah kamillah kandace kandy kania kanya
          kara kara-lynn karalee karalynn kare karee karel karen karena kari karia karie
          karil karilynn karin karina karine kariotta karisa karissa karita karla karlee
          karleen karlen karlene karlie karlotta karlotte karly karlyn karmen karna karol
          karola karole karolina karoline karoly karon karrah karrie karry kary karyl
          karylin karyn kasey kass kassandra kassey kassi kassia kassie kat kata katalin
          kate katee katerina katerine katey kath katha katharina katharine katharyn kathe
          katherina katherine katheryn kathi kathie kathleen kathlin kathrine kathryn
          kathryne kathy kathye kati katie katina katine katinka katleen katlin katrina
          katrine katrinka katti kattie katuscha katusha katy katya kay kaycee kaye kayla
          kayle kaylee kayley kaylil kaylyn keeley keelia keely kelcey kelci kelcie kelcy
          kelila kellen kelley kelli kellia kellie kellina kellsie kelly kellyann kelsey
          kelsi kelsy kendra kendre kenna keri keriann kerianne kerri kerrie kerrill
          kerrin kerry kerstin kesley keslie kessia kessiah ketti kettie ketty kevina
          kevyn ki kiah kial kiele kiersten kikelia kiley kim kimberlee kimberley kimberli
          kimberly kimberlyn kimbra kimmi kimmie kimmy kinna kip kipp kippie kippy kira
          kirbee kirbie kirby kiri kirsten kirsteni kirsti kirstin kirstyn kissee kissiah
          kissie kit kitti kittie kitty kizzee kizzie klara klarika klarrisa konstance
          konstanze koo kora koral koralle kordula kore korella koren koressa kori korie
          korney korrie korry kris krissie krissy krista kristal kristan kriste kristel
          kristen kristi kristien kristin kristina kristine kristy kristyn krysta krystal
          krystalle krystle krystyna kyla kyle kylen kylie kylila kylynn kym kynthia
          kyrstin lacee lacey lacie lacy ladonna laetitia laina lainey lana lanae lane
          lanette laney lani lanie lanita lanna lanni lanny lara laraine lari larina
          larine larisa larissa lark laryssa latashia latia latisha latrena latrina laura
          lauraine laural lauralee laure lauree laureen laurel laurella lauren laurena
          laurene lauretta laurette lauri laurianne laurice laurie lauryn lavena laverna
          laverne lavina lavinia lavinie layla layne layney lea leah leandra leann leanna
          leanor leanora lebbie leda lee leeann leeanne leela leelah leena leesa leese
          legra leia leigh leigha leila leilah leisha lela lelah leland lelia lena lenee
          lenette lenka lenna lenora lenore leodora leoine leola leoline leona leonanie
          leone leonelle leonie leonora leonore leontine leontyne leora leshia lesley
          lesli leslie lesly lesya leta lethia leticia letisha letitia letizia letta letti
          lettie letty lexi lexie lexine lexis lexy leyla lezlie lia lian liana liane
          lianna lianne lib libbey libbi libbie libby licha lida lidia liesa lil lila
          lilah lilas lilia lilian liliane lilias lilith lilla lilli lillian lillis
          lilllie lilly lily lilyan lin lina lind linda lindi lindie lindsay lindsey
          lindsy lindy linea linell linet linette linn linnea linnell linnet linnie linzy
          lira lisa lisabeth lisbeth lise lisetta lisette lisha lishe lissa lissi lissie
          lissy lita liuka liv liva livia livvie livvy livvyy livy liz liza lizabeth
          lizbeth lizette lizzie lizzy loella lois loise lola loleta lolita lolly lona
          lonee loni lonna lonni lonnie lora lorain loraine loralee loralie loralyn loree
          loreen lorelei lorelle loren lorena lorene lorenza loretta lorette lori loria
          lorianna lorianne lorie lorilee lorilyn lorinda lorine lorita lorna lorne
          lorraine lorrayne lorri lorrie lorrin lorry lory lotta lotte lotti lottie lotty
          lou louella louisa louise louisette loutitia lu luce luci lucia luciana lucie
          lucienne lucila lucilia lucille lucina lucinda lucine lucita lucky lucretia lucy
          ludovika luella luelle luisa luise lula lulita lulu lura lurette lurleen lurlene
          lurline lusa luz lyda lydia lydie lyn lynda lynde lyndel lyndell lyndsay lyndsey
          lyndsie lyndy lynea lynelle lynett lynette lynn lynna lynne lynnea lynnell
          lynnelle lynnet lynnett lynnette lynsey lyssa mab mabel mabelle mable mada
          madalena madalyn maddalena maddi maddie maddy madel madelaine madeleine madelena
          madelene madelin madelina madeline madella madelle madelon madelyn madge madlen
          madlin madonna mady mae maegan mag magda magdaia magdalen magdalena magdalene
          maggee maggi maggie maggy mahala mahalia maia maible maiga maighdiln mair maire
          maisey maisie maitilde mala malanie malena malia malina malinda malinde malissa
          malissia mallissa mallorie mallory malorie malory malva malvina malynda mame
          mamie manda mandi mandie mandy manon manya mara marabel marcela marcelia
          marcella marcelle marcellina marcelline marchelle marci marcia marcie marcile
          marcille marcy mareah maren marena maressa marga margalit margalo margaret
          margareta margarete margaretha margarethe margaretta margarette margarita
          margaux marge margeaux margery marget margette margi margie margit margo margot
          margret marguerite margy mari maria mariam marian mariana mariann marianna
          marianne maribel maribelle maribeth marice maridel marie marie-ann marie-jeanne
          marieann mariejeanne mariel mariele marielle mariellen marietta mariette
          marigold marijo marika marilee marilin marillin marilyn marin marina marinna
          marion mariquilla maris marisa mariska marissa marita maritsa mariya marj marja
          marje marji marjie marjorie marjory marjy marketa marla marlane marleah marlee
          marleen marlena marlene marley marlie marline marlo marlyn marna marne marney
          marni marnia marnie marquita marrilee marris marrissa marsha marsiella marta
          martelle martguerita martha marthe marthena marti martica martie martina martita
          marty martynne mary marya maryann maryanna maryanne marybelle marybeth maryellen
          maryjane maryjo maryl marylee marylin marylinda marylou marylynne maryrose marys
          marysa masha matelda mathilda mathilde matilda matilde matti mattie matty maud
          maude maudie maura maure maureen maureene maurene maurine maurise maurita
          maurizia mavis mavra max maxi maxie maxine maxy may maybelle maye mead meade
          meagan meaghan meara mechelle meg megan megen meggi meggie meggy meghan meghann
          mehetabel mei mel mela melamie melania melanie melantha melany melba melesa
          melessa melicent melina melinda melinde melisa melisande melisandra melisenda
          melisent melissa melisse melita melitta mella melli mellicent mellie mellisa
          mellisent melloney melly melodee melodie melody melonie melony melosa melva
          mercedes merci mercie mercy meredith meredithe meridel meridith meriel merilee
          merilyn meris merissa merl merla merle merlina merline merna merola merralee
          merridie merrie merrielle merrile merrilee merrili merrill merrily merry mersey
          meryl meta mia micaela michaela michaelina michaeline michaella michal michel
          michele michelina micheline michell michelle micki mickie micky midge mignon
          mignonne miguela miguelita mikaela mil mildred mildrid milena milicent milissent
          milka milli millicent millie millisent milly milzie mimi min mina minda mindy
          minerva minetta minette minna minnaminnie minne minni minnie minnnie minny minta
          miquela mira mirabel mirabella mirabelle miran miranda mireielle mireille
          mirella mirelle miriam mirilla mirna misha missie missy misti misty mitzi
          modesta modestia modestine modesty moina moira moll mollee molli mollie molly
          mommy mona monah monica monika monique mora moreen morena morgan morgana
          morganica morganne morgen moria morissa morna moselle moyna moyra mozelle muffin
          mufi mufinella muire mureil murial muriel murielle myra myrah myranda myriam
          myrilla myrle myrlene myrna myrta myrtia myrtice myrtie myrtle nada nadean
          nadeen nadia nadine nadiya nady nadya nalani nan nana nananne nance nancee
          nancey nanci nancie nancy nanete nanette nani nanice nanine nannette nanni
          nannie nanny nanon naoma naomi nara nari nariko nat nata natala natalee natalie
          natalina nataline natalya natasha natassia nathalia nathalie natividad natka
          natty neala neda nedda nedi neely neila neile neilla neille nelia nelie nell
          nelle nelli nellie nelly nerissa nerita nert nerta nerte nerti nertie nerty
          nessa nessi nessie nessy nesta netta netti nettie nettle netty nevsa neysa
          nichol nichole nicholle nicki nickie nicky nicol nicola nicole nicolea nicolette
          nicoli nicolina nicoline nicolle nikaniki nike niki nikki nikkie nikoletta
          nikolia nina ninetta ninette ninnetta ninnette ninon nissa nisse nissie nissy
          nita nixie noami noel noelani noell noella noelle noellyn noelyn noemi nola
          nolana nolie nollie nomi nona nonah noni nonie nonna nonnah nora norah norean
          noreen norene norina norine norma norri norrie norry novelia nydia nyssa octavia
          odele odelia odelinda odella odelle odessa odetta odette odilia odille ofelia
          ofella ofilia ola olenka olga olia olimpia olive olivette olivia olivie oliy
          ollie olly olva olwen olympe olympia olympie ondrea oneida onida oona opal
          opalina opaline ophelia ophelie ora oralee oralia oralie oralla oralle orel
          orelee orelia orelie orella orelle oriana orly orsa orsola ortensia otha othelia
          othella othilia othilie ottilie page paige paloma pam pamela pamelina pamella
          pammi pammie pammy pandora pansie pansy paola paolina papagena pat patience
          patrica patrice patricia patrizia patsy patti pattie patty paula paule pauletta
          paulette pauli paulie paulina pauline paulita pauly pavia pavla pearl pearla
          pearle pearline peg pegeen peggi peggie peggy pen penelopa penelope penni pennie
          penny pepi pepita peri peria perl perla perle perri perrine perry persis pet
          peta petra petrina petronella petronia petronilla petronille petunia phaedra
          phaidra phebe phedra phelia phil philipa philippa philippe philippine philis
          phillida phillie phillis philly philomena phoebe phylis phyllida phyllis phyllys
          phylys pia pier pierette pierrette pietra piper pippa pippy polly pollyanna pooh
          poppy portia pris prisca priscella priscilla prissie pru prudence prudi prudy
          prue queenie quentin querida quinn quinta quintana quintilla quintina rachael
          rachel rachele rachelle rae raeann raf rafa rafaela rafaelia rafaelita rahal
          rahel raina raine rakel ralina ramona ramonda rana randa randee randene randi
          randie randy ranee rani rania ranice ranique ranna raphaela raquel raquela rasia
          rasla raven ray raychel raye rayna raynell rayshell rea reba rebbecca rebe
          rebeca rebecca rebecka rebeka rebekah rebekkah ree reeba reena reeta reeva regan
          reggi reggie regina regine reiko reina reine remy rena renae renata renate rene
          renee renell renelle renie rennie reta retha revkah rey reyna rhea rheba rheta
          rhetta rhiamon rhianna rhianon rhoda rhodia rhodie rhody rhona rhonda riane
          riannon rianon rica ricca rici ricki rickie ricky riki rikki rina risa rita riva
          rivalee rivi rivkah rivy roana roanna roanne robbi robbie robbin robby robbyn
          robena robenia roberta robin robina robinet robinett robinetta robinette robinia
          roby robyn roch rochell rochella rochelle rochette roda rodi rodie rodina rois
          romola romona romonda romy rona ronalda ronda ronica ronna ronni ronnica ronnie
          ronny roobbie rora rori rorie rory ros rosa rosabel rosabella rosabelle rosaleen
          rosalia rosalie rosalind rosalinda rosalinde rosaline rosalyn rosalynd rosamond
          rosamund rosana rosanna rosanne rose roseann roseanna roseanne roselia roselin
          roseline rosella roselle rosemaria rosemarie rosemary rosemonde rosene rosetta
          rosette roshelle rosie rosina rosita roslyn rosmunda rosy row rowe rowena roxana
          roxane roxanna roxanne roxi roxie roxine roxy roz rozalie rozalin rozamond
          rozanna rozanne roze rozele rozella rozelle rozina rubetta rubi rubia rubie
          rubina ruby ruperta ruth ruthann ruthanne ruthe ruthi ruthie ruthy ryann rycca
          saba sabina sabine sabra sabrina sacha sada sadella sadie sadye saidee sal
          salaidh sallee salli sallie sally sallyann sallyanne saloma salome salomi sam
          samantha samara samaria sammy sande sandi sandie sandra sandy sandye sapphira
          sapphire sara sara-ann saraann sarah sarajane saree sarena sarene sarette sari
          sarina sarine sarita sascha sasha sashenka saudra saundra savina sayre scarlet
          scarlett sean seana seka sela selena selene selestina selia selie selina selinda
          seline sella selle selma sena sephira serena serene shae shaina shaine shalna
          shalne shana shanda shandee shandeigh shandie shandra shandy shane shani shanie
          shanna shannah shannen shannon shanon shanta shantee shara sharai shari sharia
          sharity sharl sharla sharleen sharlene sharline sharon sharona sharron sharyl
          shaun shauna shawn shawna shawnee shay shayla shaylah shaylyn shaylynn shayna
          shayne shea sheba sheela sheelagh sheelah sheena sheeree sheila sheila-kathryn
          sheilah shel shela shelagh shelba shelbi shelby shelia shell shelley shelli
          shellie shelly shena sher sheree sheri sherie sherill sherilyn sherline sherri
          sherrie sherry sherye sheryl shina shir shirl shirlee shirleen shirlene shirley
          shirline shoshana shoshanna siana sianna sib sibbie sibby sibeal sibel sibella
          sibelle sibilla sibley sibyl sibylla sibylle sidoney sidonia sidonnie sigrid
          sile sileas silva silvana silvia silvie simona simone simonette simonne sindee
          siobhan sioux siouxie sisely sisile sissie sissy siusan sofia sofie sondra sonia
          sonja sonni sonnie sonnnie sonny sonya sophey sophi sophia sophie sophronia
          sorcha sosanna stace stacee stacey staci stacia stacie stacy stafani star starla
          starlene starlin starr stefa stefania stefanie steffane steffi steffie stella
          stepha stephana stephani stephanie stephannie stephenie stephi stephie stephine
          stesha stevana stevena stoddard storm stormi stormie stormy sue suellen sukey
          suki sula sunny sunshine susan susana susanetta susann susanna susannah susanne
          susette susi susie susy suzann suzanna suzanne suzette suzi suzie suzy sybil
          sybila sybilla sybille sybyl sydel sydelle sydney sylvia tabatha tabbatha tabbi
          tabbie tabbitha tabby tabina tabitha taffy talia tallia tallie tallou tallulah
          tally talya talyah tamar tamara tamarah tamarra tamera tami tamiko tamma tammara
          tammi tammie tammy tamqrah tamra tana tandi tandie tandy tanhya tani tania
          tanitansy tansy tanya tara tarah tarra tarrah taryn tasha tasia tate tatiana
          tatiania tatum tawnya tawsha ted tedda teddi teddie teddy tedi tedra teena
          teirtza teodora tera teresa terese teresina teresita teressa teri teriann terra
          terri terrie terrijo terry terrye tersina terza tess tessa tessi tessie tessy
          thalia thea theadora theda thekla thelma theo theodora theodosia theresa therese
          theresina theresita theressa therine thia thomasa thomasin thomasina thomasine
          tiena tierney tiertza tiff tiffani tiffanie tiffany tiffi tiffie tiffy tilda
          tildi tildie tildy tillie tilly tim timi timmi timmie timmy timothea tina tine
          tiphani tiphanie tiphany tish tisha tobe tobey tobi toby tobye toinette toma
          tomasina tomasine tomi tommi tommie tommy toni tonia tonie tony tonya tonye
          tootsie torey tori torie torrie tory tova tove tracee tracey traci tracie tracy
          trenna tresa trescha tressa tricia trina trish trisha trista trix trixi trixie
          trixy truda trude trudey trudi trudie trudy trula tuesday twila twyla tybi tybie
          tyne ula ulla ulrica ulrika ulrikaumeko ulrike umeko una ursa ursala ursola
          ursula ursulina ursuline uta val valaree valaria vale valeda valencia valene
          valenka valentia valentina valentine valera valeria valerie valery valerye
          valida valina valli vallie vally valma valry van vanda vanessa vania vanna vanni
          vannie vanny vanya veda velma velvet venita venus vera veradis vere verena
          verene veriee verile verina verine verla verna vernice veronica veronika
          veronike veronique vevay vi vicki vickie vicky victoria vida viki vikki vikky
          vilhelmina vilma vin vina vinita vinni vinnie vinny viola violante viole violet
          violetta violette virgie virgina virginia virginie vita vitia vitoria vittoria
          viv viva vivi vivia vivian viviana vivianna vivianne vivie vivien viviene
          vivienne viviyan vivyan vivyanne vonni vonnie vonny vyky wallie wallis walliw
          wally waly wanda wandie wandis waneta wanids wenda wendeline wendi wendie wendy
          wendye wenona wenonah whitney wileen wilhelmina wilhelmine wilie willa
          willabella willamina willetta willette willi willie willow willy willyt wilma
          wilmette wilona wilone wilow windy wini winifred winna winnah winne winni winnie
          winnifred winny winona winonah wren wrennie wylma wynn wynne wynnie wynny
          xaviera xena xenia xylia xylina yalonda yasmeen yasmin yelena yetta yettie yetty
          yevette ynes ynez yoko yolanda yolande yolane yolanthe yoshi yoshiko yovonnda
          ysabel yvette yvonne zabrina zahara zandra zaneta zara zarah zaria zarla zea
          zelda zelma zena zenia zia zilvia zita zitella zoe zola zonda zondra zonnya zora
          zorah zorana zorina zorine zsazsa zulema zuzana)
       (a able above absent absolute abstract abundant academic acceptable accepted accessible
          accurate accused active actual acute added additional adequate adjacent administrative
          adorable advanced adverse advisory aesthetic afraid aggregate aggressive agreeable
          agreed agricultural alert alive alleged allied alone alright alternative amateur
          amazing ambitious amused ancient angry annoyed annual anonymous anxious appalling
          apparent applicable appropriate arbitrary architectural armed arrogant artificial
          artistic ashamed asleep assistant associated atomic attractive automatic autonomous
          available average awake aware awful awkward back bad balanced bare basic beautiful
          beneficial better bewildered big binding biological bitter bizarre blank blind blonde
          bloody blushing boiling bold bored boring bottom brainy brave breakable breezy brief
          bright brilliant broad broken bumpy burning busy calm capable capitalist careful casual
          causal cautious central certain changing characteristic charming cheap cheerful chemical
          chief chilly chosen christian chronic chubby circular civic civil civilian classic
          classical clean clear clever clinical close closed cloudy clumsy coastal cognitive
          coherent cold collective colonial colorful colossal coloured colourful combative
          combined comfortable coming commercial common communist compact comparable
          comparative compatible competent competitive complete complex complicated
          comprehensive compulsory conceptual concerned concrete condemned confident
          confidential confused conscious conservation conservative considerable consistent
          constant constitutional contemporary content continental continued continuing
          continuous controlled controversial convenient conventional convinced convincing
          cooing cool cooperative corporate correct corresponding costly courageous crazy
          creative creepy criminal critical crooked crowded crucial crude cruel cuddly
          cultural curious curly current curved cute daily damaged damp dangerous dark dead deaf
          deafening dear decent decisive deep defeated defensive defiant definite deliberate
          delicate delicious delighted delightful democratic dependent depressed desirable desperate
          detailed determined developed developing devoted different difficult digital diplomatic
          direct dirty disabled disappointed disastrous disciplinary disgusted distant distinct
          distinctive distinguished disturbed disturbing diverse divine dizzy domestic dominant
          double doubtful drab dramatic dreadful driving drunk dry dual due dull dusty dutch
          dying dynamic eager early eastern easy economic educational eerie effective efficient
          elaborate elated elderly eldest electoral electric electrical electronic elegant eligible
          embarrassed embarrassing emotional empirical empty enchanting encouraging endless energetic
          enormous enthusiastic entire entitled envious environmental equal equivalent essential
          established estimated ethical ethnic eventual everyday evident evil evolutionary exact
          excellent exceptional excess excessive excited exciting exclusive existing exotic expected
          expensive experienced experimental explicit extended extensive external extra extraordinary
          extreme exuberant faint fair faithful familiar famous fancy fantastic far fascinating
          fashionable fast fat fatal favourable favourite federal fellow female feminist few fierce
          filthy final financial fine firm fiscal fit fixed flaky flat flexible fluffy fluttering
          flying following fond foolish foreign formal formidable forthcoming fortunate forward
          fragile frail frantic free frequent fresh friendly frightened front frozen full fun
          functional fundamental funny furious future fuzzy gastric gay general generous genetic
          gentle genuine geographical giant gigantic given glad glamorous gleaming global glorious
          golden good gorgeous gothic governing graceful gradual grand grateful greasy great
          grieving grim gross grotesque growing grubby grumpy guilty handicapped handsome happy
          hard harsh head healthy heavy helpful helpless hidden high hilarious hissing historic
          historical hollow holy homeless homely hon honest horizontal horrible hostile hot huge
          human hungry hurt hushed husky icy ideal identical ideological ill illegal imaginative
          immediate immense imperial implicit important impossible impressed impressive improved
          inadequate inappropriate inc inclined increased increasing incredible independent indirect
          individual industrial inevitable influential informal inherent initial injured inland inner
          innocent innovative inquisitive instant institutional insufficient intact integral
          integrated intellectual intelligent intense intensive interested interesting interim interior
          intermediate internal international intimate invisible involved irrelevant isolated
          itchy jealous jittery joint jolly joyous judicial juicy junior just keen key kind known
          labour large late latin lazy leading left legal legislative legitimate lengthy lesser level
          lexical liable liberal light like likely limited linear linguistic liquid literary little
          live lively living local logical lonely long loose lost loud lovely low loyal ltd lucky mad
          magic magnetic magnificent main major male mammoth managerial managing manual many marginal
          marine marked married marvellous marxist mass massive mathematical mature maximum mean
          meaningful mechanical medical medieval melodic melted mental mere metropolitan mid middle
          mighty mild military miniature minimal minimum ministerial minor miserable misleading missing
          misty mixed moaning mobile moderate modern modest molecular monetary monthly moral motionless
          muddy multiple mushy musical mute mutual mysterious naked narrow nasty national native natural
          naughty naval near nearby neat necessary negative neighbouring nervous net neutral new nice
          noble noisy normal northern nosy notable novel nuclear numerous nursing nutritious nutty
          obedient objective obliged obnoxious obvious occasional occupational odd official ok okay
          old olympic only open operational opposite optimistic oral ordinary organic organisational
          original orthodox other outdoor outer outrageous outside outstanding overall overseas
          overwhelming painful pale panicky parallel parental parliamentary partial particular passing
          passive past patient payable peaceful peculiar perfect permanent persistent personal petite
          philosophical physical plain planned plastic pleasant pleased poised polite political poor
          popular positive possible potential powerful practical precious precise preferred pregnant
          preliminary premier prepared present presidential pretty previous prickly primary prime
          primitive principal printed prior private probable productive professional profitable
          profound progressive prominent promising proper proposed prospective protective protestant
          proud provincial psychiatric psychological public puny pure purring puzzled quaint qualified
          quarrelsome querulous quick quickest quiet quintessential quixotic racial radical rainy
          random rapid rare raspy rational ratty raw ready real realistic rear reasonable recent
          reduced redundant regional registered regular regulatory related relative relaxed relevant
          reliable relieved religious reluctant remaining remarkable remote renewed representative
          repulsive required resident residential resonant respectable respective responsible resulting
          retail retired revolutionary rich ridiculous right rigid ripe rising rival roasted robust
          rolling romantic rotten rough round royal rubber rude ruling running rural sacred sad safe
          salty satisfactory satisfied scared scary scattered scientific scornful scrawny screeching
          secondary secret secure select selected selective selfish semantic senior sensible sensitive
          separate serious severe sexual shaggy shaky shallow shared sharp sheer shiny shivering
          shocked short shrill shy sick significant silent silky silly similar simple single skilled
          skinny sleepy slight slim slimy slippery slow small smart smiling smoggy smooth social
          socialist soft solar sole solid sophisticated sore sorry sound sour southern soviet spare
          sparkling spatial special specific specified spectacular spicy spiritual splendid spontaneous
          sporting spotless spotty square squealing stable stale standard static statistical statutory
          steady steep sticky stiff still stingy stormy straight straightforward strange strategic
          strict striking striped strong structural stuck stupid subjective subsequent substantial
          subtle successful successive sudden sufficient suitable sunny super superb superior
          supporting supposed supreme sure surprised surprising surrounding surviving suspicious sweet
          swift symbolic sympathetic systematic tall tame tart tasteless tasty technical technological
          teenage temporary tender tense terrible territorial testy then theoretical thick thin
          thirsty thorough thoughtful thoughtless thundering tight tiny tired top tory total tough
          toxic traditional tragic tremendous tricky tropical troubled typical ugliest ugly ultimate
          unable unacceptable unaware uncertain unchanged uncomfortable unconscious underground
          underlying unemployed uneven unexpected unfair unfortunate unhappy uniform uninterested
          unique united universal unknown unlikely unnecessary unpleasant unsightly unusual unwilling
          upper upset uptight urban urgent used useful useless usual vague valid valuable variable
          varied various varying vast verbal vertical very vicarious vicious victorious violent
          visible visiting visual vital vitreous vivacious vivid vocal vocational voiceless voluminous
          voluntary vulnerable wandering warm wasteful watery weak wealthy weary wee weekly weird
          welcome well western wet whispering whole wicked wide widespread wild wilful willing willowy
          wily wise wispy wittering witty wonderful wooden working worldwide worried worrying worthwhile
          worthy written wrong xenacious xenial xenogeneic xenophobic xeric xerothermic yabbering yammering
          yappiest yappy yawning yearling yearning yeasty yelling yelping yielding yodelling young youngest
          youthful ytterbic yucky yummy zany zealous zeroth zestful zesty zippy zonal zoophagous zygomorphic
          zygotic)
       (m baby booble bunker cuddle cuddly cutie doodle foofie gooble honey kissie lover lovey moofie
          mooglie moopie moopsie nookum poochie poof poofie pookie schmoopie schnoogle schnookie
          schnookum smooch smoochie smoosh snoogle snoogy snookie snookum snuggy sweetie woogle woogy wookie
          wookum wuddle wuddly wuggy wunny)
       (M boo bunch bunny cake cakes cute darling dumpling dumplings
          face foof goo head kin kins lips love mush pie poo pooh
          pook pums)
       (D b bl br cl d f fl fr g gh gl gr h j k kl m n p th w)
       (sw ackbar adi gallia anakin skywalker arvel crynyd ayla secura bail prestor organa barriss offee
           ben quadinaros beru whitesun lars bib fortuna biggs darklighter boba fett bossk chewbacca cliegg
           lars cordé darth maul darth vader dexter jettster dooku dormé dud bolt eeth koth finis valorum
           gasgano greedo gregar typho grievous han solo ig-88 jabba desilijic tiure jango fett jar-jar binks
           jek tono porkins jocasta nu ki-adi-mundi kit fisto lama su lando calrissian leia organa lobot luke
           skywalker luminara unduli mace windu mas amedda mon mothma nien nunb nute gunray obi-wan kenobi
           owen lars padmé amidala palpatine plo koon poggle the lesser quarsh panaka qui-gon jinn ratts
           tyerel raymus antilles ric olié roos tarpals rugor nass saesee tiin san hill sebulba shaak ti shmi
           skywalker sly moore tarfful taun we tion medon wat tambor watto wedge antilles wicket systri warrick
           wilhuff tarkin yarael poof yoda zam wesell)
       (d elch idiot ob og ok olph olt omph ong onk oo oob oof oog
          ook ooz org ork orm oron ub uck ug ulf ult um umb ump umph
          un unb ung unk unph unt uzz)))

(def (randth lst)
     ;; Select random element from the given list.
     (list-ref lst (random-integer (length lst))))

(def (namegen sexp)
     ;; Generate a name from the given sexp generator.
     (cond
      ((null? sexp) "")
      ((string? sexp) sexp)
      ((symbol? sexp) (namegen-select sexp))
      ((list? sexp)
       (string-append (if (list? (car sexp)) (namegen (randth (car sexp)))
                          (namegen (car sexp)))
                      (namegen (cdr sexp))))))

(def (namegen-select sym)
     ;; Select a replacement for the given symbol.
     (if (null? (assoc sym namegen-subs))
         (error (string-append "Invalid substitution symbol: " (format "%s" sym)))
         (symbol->string (randth (cdr (assoc sym namegen-subs))))))
