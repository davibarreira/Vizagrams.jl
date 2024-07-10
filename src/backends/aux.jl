function hyphen_to_camelcase(str::AbstractString)
    parts = split(str, "-")
    result = ""
    for (i, part) in enumerate(parts)
        if i == 1
            result *= part
        else
            result *= uppercase(part[1]) * lowercase(part[2:end])
        end
    end
    return result
end

function camelcase_to_hyphen(str::AbstractString)
    result = ""
    for (i, char) in enumerate(str)
        if isuppercase(char) && i != 1
            result *= "-" * lowercase(char)
        else
            result *= char
        end
    end
    return result
end

function style_string_to_dict(style_string::String)
    # Split the string based on semicolon delimiter
    style_attributes = split(style_string, ";")

    # Initialize an empty dictionary
    style_dict = Dict()

    # Iterate over each attribute and split based on colon delimiter
    for attribute in style_attributes
        parts = split(attribute, ":")
        if length(parts) == 2
            key = Meta.parse(hyphen_to_camelcase(strip(parts[1])))
            value = strip(parts[2])
            style_dict[key] = value
        end
    end
    return style_dict
end
