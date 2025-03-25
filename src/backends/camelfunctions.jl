"""
hyphen_to_camelcase(str::AbstractString) -> String

Converts a hyphen-separated string (`str`) into camelCase format. 
The first segment remains lowercase, and subsequent segments 
are capitalized.

# Arguments
- `str::AbstractString`: The input string with segments separated by hyphens.

# Returns
- `String`: The camelCase formatted string.

"""
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

"""
camelcase_to_hyphen(str::AbstractString) -> String

Converts a string from camelCase to hyphen-case.

# Arguments
- `str::AbstractString`: The input string in camelCase format.

# Returns
- A `String` where uppercase letters in the input are replaced with their lowercase equivalents, prefixed by a hyphen (`-`), except for the first character.
"""
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

"""
style_string_to_dict(style_string::String) -> Dict

Converts a CSS style string into a dictionary with keys in camelCase format.

# Arguments
- `style_string::String`: A string containing CSS style attributes, where each attribute is separated by a semicolon (`;`) and each key-value pair is separated by a colon (`:`).

# Returns
- `Dict`: A dictionary where the keys are converted to camelCase format and the values are the corresponding style values.
"""
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
