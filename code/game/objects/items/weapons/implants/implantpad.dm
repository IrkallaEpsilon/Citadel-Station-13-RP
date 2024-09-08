/obj/item/implantpad
	name = "implantpad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/implantcase/case = null
	var/broadcasting = null
	var/listening = 1.0



/obj/item/implantpad/proc/update()
	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return


/obj/item/implantpad/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if ((src.case && user.is_holding(src)))
		user.put_in_active_hand(case)

		src.case.add_fingerprint(user)
		src.case = null

		src.add_fingerprint(user)
		update()
	else
		return ..()
	return


/obj/item/implantpad/attackby(obj/item/implantcase/C as obj, mob/user as mob)
	..()
	if(istype(C, /obj/item/implantcase))
		if(!( src.case ))
			if(!user.attempt_insert_item_for_installation(C, src))
				return
			src.case = C
	else
		return
	src.update()
	return


/obj/item/implantpad/attack_self(mob/user)
	. = ..()
	if(.)
		return
	user.set_machine(src)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if (src.case)
		if(src.case.imp)
			if(istype(src.case.imp, /obj/item/implant))
				dat += src.case.imp.get_data()
				if(istype(src.case.imp, /obj/item/implant/tracking))
					dat += {"ID (1-100):
					<A href='byond://?src=\ref[src];tracking_id=-10'>-</A>
					<A href='byond://?src=\ref[src];tracking_id=-1'>-</A> [case.imp:id]
					<A href='byond://?src=\ref[src];tracking_id=1'>+</A>
					<A href='byond://?src=\ref[src];tracking_id=10'>+</A><BR>"}
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")
	return


/obj/item/implantpad/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src)) || ((in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_machine(src)
		if (href_list["tracking_id"])
			var/obj/item/implant/tracking/T = src.case.imp
			T.id += text2num(href_list["tracking_id"])
			T.id = min(1000, T.id)
			T.id = max(1, T.id)

		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return
