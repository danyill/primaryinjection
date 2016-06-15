︠97e2656e-02e8-421e-a09f-e238444197a3i︠
%md
# Transformer Current Primary Injection Tests
* Daniel Mulholland
* 16/06/2016


︡effebc65-3c90-4230-a81f-d6d99bf6d1ea︡{"done":true,"md":"# Transformer Current Primary Injection Tests\n* Daniel Mulholland\n* 16/06/2016"}
︠827307a4-24ee-441d-8ef4-2134b40fa2bbs︠
import xml.etree.ElementTree as ET
︡d60d896a-6469-41cb-a784-6c9195e6d07b︡{"done":true}︡
︠06c0d709-9bb8-48e6-8799-fef15e9c0e3bs︠
def processSVG(listofchanges, filename = 'sketch_primary_current_injection.svg', outname = 'sketch_primary_current_injection_filled_in.svg'):
    tree = ET.parse(filename)
    root = tree.getroot()
    ns = {'svg': 'http://www.w3.org/2000/svg'}

    for texttochange in listofchanges:
        myelement = root.findall(".//svg:text[@id='" + texttochange[0] + "']/svg:tspan", ns)

        if myelement == []:
            print "Failed for: " + texttochange[0]
        else:
            myelement[0].text = texttochange[1]

    tree.write(outname)
︡c46a3579-698b-4838-b0ee-4fc118a461a1︡{"done":true}︡
︠5f7c02c0-1d91-4171-bfb7-27688574fd0as︠
def eng_string( x, format='%s', si=False):
    '''
    Returns float/int value <x> formatted in a simplified engineering format -
    using an exponent that is a multiple of 3.

    format: printf-style string used to format the value before the exponent.

    si: if true, use SI suffix for exponent, e.g. k instead of e3, n instead of
    e-9 etc.

    E.g. with format='%.2f':
        1.23e-08 => 12.30e-9
             123 => 123.00
          1230.0 => 1.23e3
      -1230000.0 => -1.23e6

    and with si=True:
          1230.0 => 1.23k
      -1230000.0 => -1.23M
    '''
    sign = ''
    if x < 0:
        x = -x
        sign = '-'
    exp = int( math.floor( math.log10( x)))
    exp3 = exp - ( exp % 3)
    x3 = x / ( 10 ** exp3)

    if si and exp3 >= -24 and exp3 <= 24 and exp3 != 0:
        exp3_text = 'yzafpnum kMGTPEZY'[ ( exp3 - (-24)) / 3]
    elif exp3 == 0:
        exp3_text = ''
    else:
        exp3_text = ' e%s' % exp3

    return ( '%s'+format+ ' ' + '%s') % ( sign, x3, exp3_text)
︡64ca95ce-64c4-47b3-b63c-5f404ada0ced︡{"done":true}︡
︠ef29ec63-c94e-4aae-bfab-6bbfc568b949s︠
@interact(layout=None)
def _(hv_checkbox = checkbox(True, label='Inject on HV'),
      mv_checkbox = checkbox(False, label='Inject on MV'),
      tx_mva = slider(1, 250, default=120, step_size=1, label='Transformer MVA'),
      tx_z1 = slider(0, 30, default=20, step_size=1, label='Impedance (Z1 %)'),
      tx_hv_voltage = slider([6.6,11,22,33,50,66,110,220,400], default=220, step_size=1, label='HV Voltage'),
      tx_mv_voltage = slider([6.6,11,22,33,50,66,110,220,400], default=110, step_size=1, label='MV Voltage'),
      hv_ct_ratio = slider([200,300,400,500,600,700,800,1000,1200,1400,1600,2000,2400], default=400, step_size=1, label='HV primary current CT rating'),
      mv_ct_ratio = slider([200,300,400,500,600,700,800,1000,1200,1400,1600,2000,2400], default=600, step_size=1, label='MV primary current CT rating'),
      ls_voltage = slider(1, 500, default=415, step_size=1, label='Local Service Voltage')):

    picture_elements = []
    have_error = False

    if (hv_checkbox and mv_checkbox) or (not hv_checkbox and not mv_checkbox):
        have_error = True
        print("Error: You cannot select to inject on both HV and MV or neither. Please select just one option")

    if tx_hv_voltage < tx_mv_voltage:
        have_error = True
        print("Error: HV and MV voltage must be different. Please re-select")

    if have_error == True:
        return

    if hv_checkbox:
        picture_elements.append(['hv-node-name', 'HV'])
        picture_elements.append(['mv-node-name', 'MV'])
        picture_elements.append(['CTR-left', str(hv_ct_ratio) + '/1'])
        picture_elements.append(['CTR-right', str(mv_ct_ratio) + '/1'])
        picture_elements.append(['TX-ratio', str(tx_hv_voltage) + '/' + str(tx_mv_voltage)])
    elif mv_checkbox:
        picture_elements.append(['hv-node-name', 'MV'])
        picture_elements.append(['mv-node-name', 'HV'])
        picture_elements.append(['CTR-left', str(mv_ct_ratio) + '/1'])
        picture_elements.append(['CTR-right', str(hv_ct_ratio) + '/1'])
        picture_elements.append(['TX-ratio', str(tx_mv_voltage) + '/' + str(tx_hv_voltage)])

    picture_elements.append(['test-voltage', str(ls_voltage) + ' V'])
    picture_elements.append(['TX-MVA', str(tx_mva) + ' MVA'])
    picture_elements.append(['TX-Z1', str(tx_z1) + '%'])

    V_base = 0
    if hv_checkbox:
        V_base = tx_hv_voltage
    elif mv_checkbox:
        V_base = tx_mv_voltage

    S_base = tx_mva
    Z_base = (V_base^2)/S_base

    Z_transformer = Z_base * (tx_z1/100)

    picture_elements.append(['ohms-at-voltage', eng_string(Z_transformer.n(),"%.2f") + ' ohms'])

    if hv_checkbox:
        picture_elements.append(['rated-current-left', eng_string((tx_mva*1000/(sqrt(3)*tx_hv_voltage)).n(),"%.0f",si=True) + 'A'])
        picture_elements.append(['rated-current-right', eng_string((tx_mva*1000/(sqrt(3)*tx_mv_voltage)).n(),"%.0f",si=True) + 'A'])
    elif mv_checkbox:
        picture_elements.append(['rated-current-left', eng_string((tx_mva*1000/(sqrt(3)*tx_mv_voltage)).n(),"%.0f",si=True) + 'A'])
        picture_elements.append(['rated-current-right', eng_string((tx_mva*1000/(sqrt(3)*tx_hv_voltage)).n(),"%.0f",si=True) + 'A'])

    primary_ls_current = ls_voltage/sqrt(3)/Z_transformer
    ls_kva = primary_ls_current*ls_voltage*sqrt(3)
    picture_elements.append(['test-kVA', eng_string((ls_kva).n(),"%.2f",si=True) + 'VA'])

    picture_elements.append(['test-Amps-left-0', eng_string((primary_ls_current).n(),"%.2f",si=True) + 'A'])
    picture_elements.append(['test-Amps-left-1', eng_string((primary_ls_current).n(),"%.2f",si=True) + 'A'])

    if hv_checkbox:
        picture_elements.append(['test-Amps-left-secondary', eng_string((primary_ls_current/hv_ct_ratio).n(),"%.2f",si=True)+ 'A'])
        picture_elements.append(['test-Amps-right-0', eng_string((primary_ls_current*(tx_hv_voltage/tx_mv_voltage)).n(),"%.2f", si=True) + 'A'])
        picture_elements.append(['test-Amps-right-secondary', eng_string((primary_ls_current*(tx_hv_voltage/tx_mv_voltage)/mv_ct_ratio).n(),"%.2f",si=True)+ 'A'])
    elif mv_checkbox:
        picture_elements.append(['test-Amps-left-secondary', eng_string((primary_ls_current/mv_ct_ratio).n(),"%.2f",si=True) + 'A'])
        picture_elements.append(['test-Amps-right-0', eng_string((primary_ls_current*(tx_mv_voltage/tx_hv_voltage)).n(),"%.2f",si=True) + 'A'])
        picture_elements.append(['test-Amps-right-secondary', eng_string((primary_ls_current*(tx_mv_voltage/tx_hv_voltage)/hv_ct_ratio).n(),"%.2f", si=True)+ 'A'])

    if have_error == False:
        processSVG(picture_elements)
        salvus.file('sketch_primary_current_injection_filled_in.svg')

︡f23a02f3-1f8e-4cb3-8cc8-e0f2c07db95d︡{"interact":{"controls":[{"control_type":"checkbox","default":true,"label":"Inject on HV","readonly":false,"var":"hv_checkbox"},{"control_type":"checkbox","default":false,"label":"Inject on MV","readonly":false,"var":"mv_checkbox"},{"animate":true,"control_type":"slider","default":119,"display_value":true,"label":"Transformer MVA","vals":["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191","192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207","208","209","210","211","212","213","214","215","216","217","218","219","220","221","222","223","224","225","226","227","228","229","230","231","232","233","234","235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250"],"var":"tx_mva","width":null},{"animate":true,"control_type":"slider","default":20,"display_value":true,"label":"Impedance (Z1 %)","vals":["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30"],"var":"tx_z1","width":null},{"animate":true,"control_type":"slider","default":7,"display_value":true,"label":"HV Voltage","vals":["6.60000000000000","11","22","33","50","66","110","220","400"],"var":"tx_hv_voltage","width":null},{"animate":true,"control_type":"slider","default":6,"display_value":true,"label":"MV Voltage","vals":["6.60000000000000","11","22","33","50","66","110","220","400"],"var":"tx_mv_voltage","width":null},{"animate":true,"control_type":"slider","default":2,"display_value":true,"label":"HV primary current CT rating","vals":["200","300","400","500","600","700","800","1000","1200","1400","1600","2000","2400"],"var":"hv_ct_ratio","width":null},{"animate":true,"control_type":"slider","default":4,"display_value":true,"label":"MV primary current CT rating","vals":["200","300","400","500","600","700","800","1000","1200","1400","1600","2000","2400"],"var":"mv_ct_ratio","width":null},{"animate":true,"control_type":"slider","default":414,"display_value":true,"label":"Local Service Voltage","vals":["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100","101","102","103","104","105","106","107","108","109","110","111","112","113","114","115","116","117","118","119","120","121","122","123","124","125","126","127","128","129","130","131","132","133","134","135","136","137","138","139","140","141","142","143","144","145","146","147","148","149","150","151","152","153","154","155","156","157","158","159","160","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187","188","189","190","191","192","193","194","195","196","197","198","199","200","201","202","203","204","205","206","207","208","209","210","211","212","213","214","215","216","217","218","219","220","221","222","223","224","225","226","227","228","229","230","231","232","233","234","235","236","237","238","239","240","241","242","243","244","245","246","247","248","249","250","251","252","253","254","255","256","257","258","259","260","261","262","263","264","265","266","267","268","269","270","271","272","273","274","275","276","277","278","279","280","281","282","283","284","285","286","287","288","289","290","291","292","293","294","295","296","297","298","299","300","301","302","303","304","305","306","307","308","309","310","311","312","313","314","315","316","317","318","319","320","321","322","323","324","325","326","327","328","329","330","331","332","333","334","335","336","337","338","339","340","341","342","343","344","345","346","347","348","349","350","351","352","353","354","355","356","357","358","359","360","361","362","363","364","365","366","367","368","369","370","371","372","373","374","375","376","377","378","379","380","381","382","383","384","385","386","387","388","389","390","391","392","393","394","395","396","397","398","399","400","401","402","403","404","405","406","407","408","409","410","411","412","413","414","415","416","417","418","419","420","421","422","423","424","425","426","427","428","429","430","431","432","433","434","435","436","437","438","439","440","441","442","443","444","445","446","447","448","449","450","451","452","453","454","455","456","457","458","459","460","461","462","463","464","465","466","467","468","469","470","471","472","473","474","475","476","477","478","479","480","481","482","483","484","485","486","487","488","489","490","491","492","493","494","495","496","497","498","499","500"],"var":"ls_voltage","width":null}],"flicker":false,"id":"1a978d9d-d3db-4b99-a3a7-879d8842be2d","layout":[[["hv_checkbox",12,null]],[["mv_checkbox",12,null]],[["tx_mva",12,null]],[["tx_z1",12,null]],[["tx_hv_voltage",12,null]],[["tx_mv_voltage",12,null]],[["hv_ct_ratio",12,null]],[["mv_ct_ratio",12,null]],[["ls_voltage",12,null]],[["",12,null]]],"style":"None"}}︡{"done":true}
︠c64c8beb-5aad-4b82-b217-a059c84bfd63s︠
︡94169847-d511-428e-8bca-2e1b1200d6fa︡{"done":true}︡









