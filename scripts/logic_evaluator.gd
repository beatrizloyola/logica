class_name LogicEvaluator


static func evaluate(level_id: String, vars: Dictionary) -> bool:
	match level_id:
		"backrooms":
			return vars.get("A", false) and vars.get("B", false)
		"mercado":
			return (vars.get("A", false) or vars.get("B", false)) and not (vars.get("A", false) and vars.get("B", false))
		"bathrooms":
			return (vars.get("A", false) and vars.get("B", false)) or (vars.get("C", false) and vars.get("D", false))
		"metro":
			return (vars.get("A", false) and vars.get("B", false)) or (vars.get("C", false) and not vars.get("D", false))
		"escritorio":
			return vars.get("A", false) and (vars.get("B", false) or vars.get("C", false) or vars.get("D", false))
	return false


static func get_expression_text(level_id: String) -> String:
	match level_id:
		"backrooms":  return "(A e B)"
		"mercado":    return "((A ou B) e ~(A e B))"
		"bathrooms":  return "((A e B) ou (C e D))"
		"metro":      return "((A e B) ou (C e ~D))"
		"escritorio": return "(A e (B ou C ou D))"
	return ""
