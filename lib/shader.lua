local shader = {
  light_source = lovr.graphics.newShader([[
      out vec3 FragmentPos;
      out vec3 Normal;

      vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
          Normal = lovrNormal;
          FragmentPos = (lovrModel * vertex).xyz;
          return projection * transform * vertex;
      }
    ]],
    [[
      in vec3 Normal;
      in vec3 FragmentPos;

      uniform vec4 liteColor;
      uniform vec4 ambience;
      uniform vec3 lightPos;
      uniform vec3 viewPos;
      uniform float specularStrength;
      uniform float metallic;

      vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv)
      {
        //diffuse
        vec3 norm = normalize(Normal);
        vec3 lightDir = normalize(lightPos - FragmentPos);
        float diff = max(dot(norm, lightDir), 0.0);
        vec4 diffuse = diff * liteColor;

        //specular
        vec3 viewDir = normalize(viewPos - FragmentPos);
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
        vec4 specular = specularStrength * spec * liteColor;

        vec4 baseColor = graphicsColor * texture(image, uv);

        return baseColor * (ambience + diffuse + specular);
      }
    ]],
    {}
  )
}

function shader.load()
  shader.light_source:send('liteColor', {1.0, 1.0, 1.0, 1.0})
  shader.light_source:send('ambience', {0.0, 0.0, 0.0, 1.0})
  shader.light_source:send('specularStrength', 0.8)
  shader.light_source:send('metallic', 5.0)
  shader.light_source:send('lightPos', {0.0, 30.0, 0.0})
end

return shader
